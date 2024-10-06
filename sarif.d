module sarif;

import std.json : JSONValue, JSONType;
import std.conv : to;
import std.sumtype;
import std.stdio;
import std.getopt;

// define LogicalLocation
struct LogicalLocation {
    string name;
    string fullyQualifiedName;

    JSONValue toJson() {
        return JSONValue([
            "name": name.to!JSONValue,
            "fullyQualifiedName": fullyQualifiedName.to!JSONValue
        ]);
    }
}

// define PhysicalLocation
struct PhysicalLocation {
    string uri;
    int startLine;
    int startColumn;

    JSONValue toJson() {
        return JSONValue([
            "artifactLocation": ["uri": uri.to!JSONValue].to!JSONValue,
            "region": [
                "startLine": startLine.to!JSONValue,
                "startColumn": startColumn.to!JSONValue
            ].to!JSONValue
        ]);
    }
}

// define a SARIF Result struct with a SumType for location
alias LocationType = SumType!(PhysicalLocation, LogicalLocation);

struct Result {
    string ruleId;
    LocationType location;

    // convert Result to JSON
    JSONValue toJson() {
        JSONValue locationJson = location.match!(
            (PhysicalLocation loc) => loc.toJson(),
            (LogicalLocation loc) => loc.toJson()
        );
        
        return JSONValue([
            "ruleId": ruleId.to!JSONValue,
            "location": locationJson
        ]);
    }
}

// unit tests
unittest {
    // test LogicalLocation toJson
    LogicalLocation logLoc = LogicalLocation("main", "fully.qualified.main");
    JSONValue logLocJson = logLoc.toJson();
    assert(logLocJson["name"].get!string == "main");
    assert(logLocJson["fullyQualifiedName"].get!string == "fully.qualified.main");

    // test LogicalLocation with empty values
    LogicalLocation logLocEmpty = LogicalLocation("", "");
    JSONValue logLocJsonEmpty = logLocEmpty.toJson();
    assert(logLocJsonEmpty["name"].get!string == "");
    assert(logLocJsonEmpty["fullyQualifiedName"].get!string == "");

    // test PhysicalLocation toJson
    PhysicalLocation physLoc = PhysicalLocation("file.c", 1, 10);
    JSONValue physLocJson = physLoc.toJson();
    assert(physLocJson["artifactLocation"]["uri"].get!string == "file.c");
    assert(physLocJson["region"]["startLine"].get!int == 1);
    assert(physLocJson["region"]["startColumn"].get!int == 10);

    // test PhysicalLocation with zero values
    PhysicalLocation physLocEmpty = PhysicalLocation("", 0, 0);
    JSONValue physLocJsonEmpty = physLocEmpty.toJson();
    assert(physLocJsonEmpty["artifactLocation"]["uri"].get!string == "");
    assert(physLocJsonEmpty["region"]["startLine"].get!int == 0);
    assert(physLocJsonEmpty["region"]["startColumn"].get!int == 0);

    // test PhysicalLocation with an unusual URI
    PhysicalLocation physLocInvalid = PhysicalLocation("/invalid\\path/file.c", 999999, 999999);
    JSONValue physLocJsonInvalid = physLocInvalid.toJson();
    assert(physLocJsonInvalid["artifactLocation"]["uri"].get!string == "/invalid\\path/file.c");
    assert(physLocJsonInvalid["region"]["startLine"].get!int == 999999);
    assert(physLocJsonInvalid["region"]["startColumn"].get!int == 999999);

    // test Result toJson with PhysicalLocation
    Result resultPhys = Result("rule1", LocationType(physLoc));
    JSONValue resultPhysJson = resultPhys.toJson();
    assert(resultPhysJson["ruleId"].get!string == "rule1");
    assert(resultPhysJson["location"]["artifactLocation"]["uri"].get!string == "file.c");

    // test Result toJson with LogicalLocation
    Result resultLog = Result("rule2", LocationType(logLoc));
    JSONValue resultLogJson = resultLog.toJson();
    assert(resultLogJson["ruleId"].get!string == "rule2");
    assert(resultLogJson["location"]["name"].get!string == "main");

    // test Result with empty ruleId
    Result resultEmptyRuleId = Result("", LocationType(logLoc));
    JSONValue resultEmptyRuleIdJson = resultEmptyRuleId.toJson();
    assert(resultEmptyRuleIdJson["ruleId"].get!string == "");

    // test that only PhysicalLocation appears in the JSON
    assert(resultPhysJson["location"].type == JSONType.object);
    
    // check if the "name" field is absent in PhysicalLocation
    assert(resultPhysJson["location"].get!(JSONValue[string]).get("name", JSONValue.init).type == JSONType.null_);

    // test an array of Result objects
    Result result1 = Result("rule1", LocationType(physLoc));
    Result result2 = Result("rule2", LocationType(logLoc));
    auto resultsArray = [result1.toJson(), result2.toJson()];
    assert(resultsArray.length == 2);
    assert(resultsArray[0]["ruleId"].get!string == "rule1");
    assert(resultsArray[1]["ruleId"].get!string == "rule2");
}

// main function to print results or run tests based on the flag
void main(string[] args) {
    bool runTests;
    getopt(args, "unittest", &runTests);

    if (runTests) {
        writeln("Running unit tests...");
        return;
    }

    // create a PhysicalLocation and LogicalLocation
    PhysicalLocation physicalLocation = PhysicalLocation("file.c", 1, 10);
    LogicalLocation logicalLocation = LogicalLocation("main", "fully.qualified.main");

    // create results with SumType for location
    Result resultWithPhysical = Result("rule1", LocationType(physicalLocation));
    Result resultWithLogical = Result("rule2", LocationType(logicalLocation));

    // print both results in JSON format
    writeln(resultWithPhysical.toJson().toPrettyString());
    writeln(resultWithLogical.toJson().toPrettyString());
}
