module sarif;

import std.process : executeShell;
import std.json : JSONValue;
import std.conv : to;
import std.stdio;
import std.getopt;
import std.string : splitLines, strip;

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

// enum to define the location type
enum LocationType {
    PhysicalLocation
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

// struct to represent a result such as an error, with a rule ID, message, and location
struct Result {
    string ruleId; 
    string message; 
    PhysicalLocation location; 

    // converts the result to JSON format
    JSONValue toJson() {
        return JSONValue([
            "ruleId": ruleId.to!JSONValue,
            "message": message.to!JSONValue,
            "location": location.toJson()
        ]);
    }
}

// function to manually find the index of a character in a string
int findChar(string line, char ch) {
    foreach (ulong i, c; line) {
        if (c == ch) {
            return cast(int) i; // explicit cast from ulong to int
        }
    }
    return -1; 
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
        // manually check if the line starts with the source file name (indicating an error)
        if (line[0 .. sourceFile.length] == sourceFile) {
            // use manual search to find '(' and ')'
            int fileNameEnd = findChar(line, '(');
            if (fileNameEnd == -1) continue; 
            string fileName = line[0 .. fileNameEnd].strip();

            int lineNumberStart = fileNameEnd + 1;
            int lineNumberEnd = findChar(line, ')');
            if (lineNumberEnd == -1) continue; 
            string lineNumberStr = line[lineNumberStart .. lineNumberEnd].strip();
            int lineNumber = lineNumberStr.to!int;

            // manually find the ':' for the error message start
            int errorMessageStart = findChar(line, ':');
            if (errorMessageStart == -1) continue; 
            string errorMessage = line[errorMessageStart + 1 .. $].strip();

            // create a PhysicalLocation object and Result object for this error
            PhysicalLocation location = PhysicalLocation(fileName, lineNumber, 0);
            Result resultObj = Result("DMD", errorMessage, location);
            resultsArray ~= resultObj;
        }
    }

    return resultsArray;
}

// unit tests for the SARIF-related structures
unittest {
    // test ToolInformation struct
    ToolInformation toolInfo = ToolInformation("DMD", "2.109.1");
    JSONValue toolJson = toolInfo.toJson();
    assert(toolJson["name"].get!string == "DMD");
    assert(toolJson["version"].get!string == "2.109.1");

    // test Invocation struct
    Invocation invocation = Invocation(true);
    JSONValue invocationJson = invocation.toJson();
    assert(invocationJson["executionSuccessful"].get!bool == true);

    // test PhysicalLocation struct
    PhysicalLocation location = PhysicalLocation("test.d", 10, 0);
    JSONValue locationJson = location.toJson();
    assert(locationJson["artifactLocation"]["uri"].get!string == "test.d");
    assert(locationJson["region"]["startLine"].get!int == 10);
    assert(locationJson["region"]["startColumn"].get!int == 0);

    // test Result struct
    Result result = Result("DMD", "Error: undefined identifier", location);
    JSONValue resultJson = result.toJson();
    assert(resultJson["ruleId"].get!string == "DMD");
    assert(resultJson["message"].get!string == "Error: undefined identifier");
    assert(resultJson["location"]["artifactLocation"]["uri"].get!string == "test.d");

    // test SarifReport struct
    SarifReport report = SarifReport(toolInfo, invocation, [result]);
    JSONValue reportJson = report.toJson();
    assert(reportJson["tool"]["name"].get!string == "DMD");
    assert(reportJson["invocation"]["executionSuccessful"].get!bool == true);
    assert(reportJson["results"][0]["ruleId"].get!string == "DMD");
}

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
