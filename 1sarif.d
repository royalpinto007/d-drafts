module sarif;

import std.json : JSONValue, JSONType;
import std.conv : to;
import std.sumtype;
import std.stdio;
import std.getopt;

// define Tool Information
struct ToolInformation {
    string name;
    string toolVersion; 

    JSONValue toJson() {
        return JSONValue([
            "name": name.to!JSONValue,
            "version": toolVersion.to!JSONValue 
        ]);
    }
}

// define Invocation (e.g., success of tool execution)
struct Invocation {
    bool executionSuccessful;

    JSONValue toJson() {
        return JSONValue([
            "executionSuccessful": executionSuccessful.to!JSONValue
        ]);
    }
}

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

// define Result with suggested fixes and precise location
struct Result {
    string ruleId;
    string message; // Detailed message about the issue
    LocationType location;
    string suggestedFix; // Suggested fix

    // convert Result to JSON
    JSONValue toJson() {
        JSONValue locationJson = location.match!(
            (PhysicalLocation loc) => loc.toJson(),
            (LogicalLocation loc) => loc.toJson()
        );

        return JSONValue([
            "ruleId": ruleId.to!JSONValue,
            "message": message.to!JSONValue,
            "location": locationJson,
            "suggestedFix": suggestedFix.to!JSONValue
        ]);
    }
}

// main SARIF structure that includes tool info, invocations, and results
struct SarifReport {
    ToolInformation tool;
    Invocation invocation;
    Result[] results;  // Array of results

    // Convert the entire report to JSON
    JSONValue toJson() {
        JSONValue[] resultsJson;
        foreach (result; results) {
            resultsJson ~= result.toJson();  // Append to the array
        }

        return JSONValue([
            "tool": tool.toJson(),           
            "invocation": invocation.toJson(), 
            "results": resultsJson.to!JSONValue
        ]);
    }
}

// unit tests
unittest {
    // test Tool Information
    ToolInformation toolInfo = ToolInformation("DMD", "2.109.1");
    JSONValue toolJson = toolInfo.toJson();
    assert(toolJson["name"].get!string == "DMD");
    assert(toolJson["version"].get!string == "2.109.1");

    // test Invocation success
    Invocation invocation = Invocation(true);
    JSONValue invocationJson = invocation.toJson();
    assert(invocationJson["executionSuccessful"].get!bool == true);

    // test LogicalLocation toJson
    LogicalLocation logLoc = LogicalLocation("main", "fully.qualified.main");
    JSONValue logLocJson = logLoc.toJson();
    assert(logLocJson["name"].get!string == "main");
    assert(logLocJson["fullyQualifiedName"].get!string == "fully.qualified.main");

    // test PhysicalLocation toJson
    PhysicalLocation physLoc = PhysicalLocation("test.c", 5, 20);
    JSONValue physLocJson = physLoc.toJson();
    assert(physLocJson["artifactLocation"]["uri"].get!string == "test.c");
    assert(physLocJson["region"]["startLine"].get!int == 5);
    assert(physLocJson["region"]["startColumn"].get!int == 20);

    // test Result with fix
    Result result = Result("rule1", "Variable not initialized", LocationType(physLoc), "Initialize the variable.");
    JSONValue resultJson = result.toJson();
    assert(resultJson["ruleId"].get!string == "rule1");
    assert(resultJson["message"].get!string == "Variable not initialized");
    assert(resultJson["suggestedFix"].get!string == "Initialize the variable.");

    // test SarifReport with all details
    SarifReport report = SarifReport(toolInfo, invocation, [result]);
    JSONValue reportJson = report.toJson();
    assert(reportJson["tool"]["name"].get!string == "DMD");
    assert(reportJson["invocation"]["executionSuccessful"].get!bool == true);
    assert(reportJson["results"].array.length == 1);
}

// main function to print results or run tests based on the flag
void main(string[] args) {
    bool runTests;
    getopt(args, "unittest", &runTests);

    if (runTests) {
        writeln("Running unit tests...");
        return;
    }

    // create the necessary elements for the SARIF report
    ToolInformation toolInfo = ToolInformation("DMD", "2.109.1");
    Invocation invocation = Invocation(true);

    // create a PhysicalLocation and LogicalLocation
    PhysicalLocation physicalLocation = PhysicalLocation("test.c", 5, 20);
    LogicalLocation logicalLocation = LogicalLocation("main", "fully.qualified.main");

    // create results with suggested fixes
    Result resultWithPhysical = Result("rule1", "Variable not initialized", LocationType(physicalLocation), "Initialize the variable.");
    Result resultWithLogical = Result("rule2", "Function not used", LocationType(logicalLocation), "Remove the unused function.");

    // combine everything into a SARIF report
    SarifReport report = SarifReport(toolInfo, invocation, [resultWithPhysical, resultWithLogical]);

    // print the SARIF report in JSON format
    writeln(report.toJson().toPrettyString());
}
