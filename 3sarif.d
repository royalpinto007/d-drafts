module sarif;

import std.process : executeShell;
import std.json : JSONValue, JSONType;
import std.conv : to;
import std.sumtype;
import std.stdio;
import std.getopt;
import std.string : splitLines, indexOf, strip, startsWith, endsWith;

// struct to hold tool information such as name and version
struct ToolInformation {
    string name;
    string toolVersion;

    // converts tool information to JSON format
    JSONValue toJson() {
        return JSONValue([
            "name": name.to!JSONValue,
            "version": toolVersion.to!JSONValue
        ]);
    }
}

// struct to hold invocation information, specifically if execution was successful
struct Invocation {
    bool executionSuccessful;

    // converts invocation information to JSON format
    JSONValue toJson() {
        return JSONValue([
            "executionSuccessful": executionSuccessful.to!JSONValue
        ]);
    }
}

// struct to represent the location in the code (file, line, column) where an issue occurred
struct PhysicalLocation {
    string uri; 
    int startLine; 
    int startColumn;

    // converts the physical location to JSON format
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

// sumtype alias to support various location types (currently only PhysicalLocation is defined)
alias LocationType = SumType!(PhysicalLocation);

// struct to represent a result such as an error, with a rule ID, message, and location
struct Result {
    string ruleId; 
    string message; 
    LocationType location; 

    // converts the result to JSON format
    JSONValue toJson() {
        JSONValue locationJson = location.match!(
            (PhysicalLocation loc) => loc.toJson()
        );

        return JSONValue([
            "ruleId": ruleId.to!JSONValue,
            "message": message.to!JSONValue,
            "location": locationJson
        ]);
    }
}

// struct to represent the overall SARIF report which includes tool, invocation, and results
struct SarifReport {
    ToolInformation tool; 
    Invocation invocation;
    Result[] results; 

    // converts the entire report to JSON format
    JSONValue toJson() {
        JSONValue[] resultsJson;
        foreach (result; results) {
            resultsJson ~= result.toJson();
        }

        return JSONValue([
            "tool": tool.toJson(),
            "invocation": invocation.toJson(),
            "results": resultsJson.to!JSONValue
        ]);
    }
}

// function to capture DMD compiler errors
Result[] captureDmdErrors(string sourceFile) {
    auto result = executeShell("dmd " ~ sourceFile);

    // split DMD output into lines for processing
    string[] dmdOutput = result.output.splitLines();
    Result[] resultsArray;

    foreach (line; dmdOutput) {
        // check if the line starts with the source file name (indicating an error)
        if (line.startsWith(sourceFile)) {
            // extract the file name, line number, and error message manually
            string fileName = line[0..line.indexOf("(")].strip();
            string lineNumberStr = line[line.indexOf("(") + 1 .. line.indexOf(")")].strip();
            int lineNumber = lineNumberStr.to!int;
            string errorMessage = line[line.indexOf(":") + 1 .. $].strip();

            // create a PhysicalLocation object and Result object for this error
            PhysicalLocation location = PhysicalLocation(fileName, lineNumber, 0);
            Result resultObj = Result("DMD", errorMessage, LocationType(location));
            resultsArray ~= resultObj;
        }
    }

    return resultsArray;
}

unittest {
    // test ToolInformation JSON conversion
    ToolInformation toolInfo = ToolInformation("DMD", "2.109.1");
    JSONValue toolJson = toolInfo.toJson();
    assert(toolJson["name"].get!string == "DMD");
    assert(toolJson["version"].get!string == "2.109.1");

    // test Invocation JSON conversion
    Invocation invocation = Invocation(true);
    JSONValue invocationJson = invocation.toJson();
    assert(invocationJson["executionSuccessful"].get!bool == true);

    // test Result JSON conversion
    PhysicalLocation location = PhysicalLocation("test.d", 10, 0);
    Result testResult = Result("DMD", "Error: undefined identifier", LocationType(location));
    JSONValue resultJson = testResult.toJson();
    assert(resultJson["ruleId"].get!string == "DMD");
    assert(resultJson["message"].get!string == "Error: undefined identifier");
}

// main function to parse command-line arguments and generate a SARIF report
void main(string[] args) {
    bool runTests; 
    string sourceFile = "test.d";

    // parse command-line arguments for unittest and sourceFile options
    getopt(args, "unittest", &runTests, "sourceFile", &sourceFile);

    // if running tests, just exit after unit testing
    if (runTests) {
        writeln("Running unit tests...");
        return;
    }

    // capture errors from the DMD compiler for the given source file
    Result[] results = captureDmdErrors(sourceFile);

    // create ToolInformation and Invocation objects for the SARIF report
    ToolInformation toolInfo = ToolInformation("DMD", "2.109.1");
    Invocation invocation = Invocation(results.length > 0 ? false : true);

    // generate SARIF report and print it in JSON format
    SarifReport report = SarifReport(toolInfo, invocation, results);
    writeln(report.toJson().toPrettyString());
}
