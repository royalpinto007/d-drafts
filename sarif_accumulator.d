import core.stdc.stdarg;
import core.stdc.stdio;
import core.stdc.string;
import std.array : array;
import std.conv : to;
import std.stdio : writeln, stdout, File, stderr;

struct Result {
    string ruleId;
    string message;
    string uri;
    int startLine;
    int startColumn;

    string toJson() const {
        return `{"ruleId": "` ~ ruleId ~ `", "message": "` ~ message ~ `", ` ~
               `"location": {"artifactLocation": {"uri": "` ~ uri ~ `"}, ` ~
               `"region": {"startLine": ` ~ startLine.to!string ~ `, "startColumn": ` ~ startColumn.to!string ~ `}}}`;
    }
}

struct SarifReport {
    string sarifVersion = "2.1.0"; // Renamed from 'version'
    string schema = "https://schemastore.azurewebsites.net/schemas/json/sarif-2.1.0.json";
    string toolName = "CustomTool";
    string toolVer = "1.0.0"; // Renamed from 'toolVersion'
    Result[] results;

    string toJson() const {
        string resultsJson = "[" ~ results[0].toJson();
        foreach (result; results[1 .. $]) {
            resultsJson ~= ", " ~ result.toJson();
        }
        resultsJson ~= "]";

        return `{
            "version": "` ~ sarifVersion ~ `",
            "$schema": "` ~ schema ~ `",
            "runs": [{
                "tool": {"driver": {"name": "` ~ toolName ~ `", "version": "` ~ toolVer ~ `"}},
                "results": ` ~ resultsJson ~ `
            }]
        }`;
    }
}

Result[] sarifResults;

void accumulateError(string message, string uri, int line, int column) {
    sarifResults ~= Result(
        ruleId: "CustomError",
        message: message,
        uri: uri,
        startLine: line,
        startColumn: column
    );
}

void generateFinalSarifReport() {
    if (sarifResults.length == 0) {
        writeln("No errors to report.");
        return;
    }

    SarifReport report = SarifReport(results: sarifResults);
    string sarifJson = report.toJson();
    writeln("SARIF Report:");
    writeln(sarifJson);

    stdout.flush();
}

void main() {
    accumulateError("Undefined identifier 'x'", "test1.d", 10, 5);
    accumulateError("Undefined identifier 'y'", "test2.d", 20, 8);

    generateFinalSarifReport();
}
