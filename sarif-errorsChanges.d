// Struct for SARIF Tool Information
struct ToolInformation {
    string name;
    string toolVersion;

    string toJson() nothrow {
        return `{"name": "` ~ name ~ `", "version": "` ~ toolVersion ~ `"}`;
    }
}

// Struct for SARIF Result
struct Result {
    string ruleId;  // Rule identifier (e.g., "DMD-Error", "DMD-Warning")
    string message;  // Error message
    PhysicalLocation location;  // Location where the error occurred

    string toJson() nothrow {
        return `{"ruleId": "` ~ ruleId ~ `", "message": "` ~ message ~ `", "location": ` ~ location.toJson() ~ `}`;
    }
}

// Struct for Physical Location of the Error
struct PhysicalLocation {
    string uri;  // File path (URI)
    int startLine;  // Line number where the error occurs
    int startColumn;  // Column number where the error occurs

    string toJson() nothrow {
        return `{"artifactLocation": {"uri": "` ~ uri ~ `"}, "region": {"startLine": ` ~ intToString(startLine) ~ `, "startColumn": ` ~ intToString(startColumn) ~ `}}`;
    }
}

// SARIF Report Struct
struct SarifReport {
    ToolInformation tool;  // Information about the tool (e.g., DMD)
    Invocation invocation;  // Information about the execution
    Result[] results;  // List of results (errors, warnings, etc.)

    string toJson() nothrow {
        string resultsJson = "[" ~ results[0].toJson();
        foreach (result; results[1 .. $]) {
            resultsJson ~= ", " ~ result.toJson();
        }
        resultsJson ~= "]";

        return `{"tool": ` ~ tool.toJson() ~ `, "invocation": ` ~ invocation.toJson() ~ `, "results": ` ~ resultsJson ~ `}`;
    }
}

// Struct for Invocation Information
struct Invocation {
    bool executionSuccessful;

    string toJson() nothrow {
        return `{"executionSuccessful": ` ~ (executionSuccessful ? "true" : "false") ~ `}`;
    }
}

// Function to replace writeln with fprintf for printing to stdout
void printToStdout(string message) nothrow {
    fprintf(stdout, "%.*s\n", cast(int)message.length, message.ptr);  // Cast to int
}

void generateSarifReport(const ref Loc loc, const(char)* format, va_list ap, ErrorKind kind) nothrow
{
    // Format the error message
    string formattedMessage = formatErrorMessage(format, ap);

    // Open file to write JSON output
    const(char)* fileName = "sarif_output.json";
    auto file = fopen(fileName, "w");

    if (file)
    {
        // Start writing JSON structure directly to the file
        fprintf(file, "{\n");

        // Write the invocation status
        fprintf(file, "  \"invocation\": {\n");
        fprintf(file, "    \"executionSuccessful\": false\n");
        fprintf(file, "  },\n");

        // Start the results array
        fprintf(file, "  \"results\": [\n    {\n");

        // Write location in SARIF format (artifactLocation + region)
        fprintf(file, "      \"location\": {\n");
        fprintf(file, "        \"artifactLocation\": {\n");
        fprintf(file, "          \"uri\": \"%s\"\n", loc.filename.toDString().ptr);
        fprintf(file, "        },\n");
        fprintf(file, "        \"region\": {\n");
        fprintf(file, "          \"startLine\": %d,\n", loc.linnum);
        fprintf(file, "          \"startColumn\": %d\n", loc.charnum);
        fprintf(file, "        }\n");
        fprintf(file, "      },\n");

        // Write message and ruleId
        fprintf(file, "      \"message\": \"%s\",\n", formattedMessage.ptr);
        fprintf(file, "      \"ruleId\": \"DMD\"\n");

        // Close results and array
        fprintf(file, "    }\n  ],\n");

        // Write tool information
        fprintf(file, "  \"tool\": {\n");
        fprintf(file, "    \"name\": \"DMD\",\n");
        fprintf(file, "    \"version\": \"2.109.1\"\n");
        fprintf(file, "  }\n");

        // Close JSON structure
        fprintf(file, "}\n");

        // Close the file
        fclose(file);
    }
}

// Helper function to format error messages
string formatErrorMessage(const(char)* format, va_list ap) nothrow
{
    char[2048] buffer;  // Increased buffer size to handle longer messages
    import core.stdc.stdio : vsnprintf;
    vsnprintf(buffer.ptr, buffer.length, format, ap);
    return buffer[0 .. buffer.length].dup;
}

// Function to convert int to string
string intToString(int value) nothrow {
    char[32] buffer;
    import core.stdc.stdio : sprintf;
    sprintf(buffer.ptr, "%d", value);
    return buffer[0 .. buffer.length].dup;
}

extern (C++) void verrorReport(const ref Loc loc, const(char)* format, va_list ap, ErrorKind kind, const(char)* p1 = null, const(char)* p2 = null)
{
    auto info = ErrorInfo(loc, kind, p1, p2);
    final switch (info.kind)
    {
    case ErrorKind.error:
        global.errors++;
        if (!global.gag)
        {
            info.headerColor = Classification.error;
            verrorPrint(format, ap, info);

            // Hook: Generate SARIF report for this error
            generateSarifReport(info.loc, format, ap, info.kind);

            if (global.params.v.errorLimit && global.errors >= global.params.v.errorLimit)
            {
                fprintf(stderr, "error limit (%d) reached, use `-verrors=0` to show all\n", global.params.v.errorLimit);
                fatal(); // moderate blizzard of cascading messages
            }
        }
        else
        {
            if (global.params.v.showGaggedErrors)
            {
                info.headerColor = Classification.gagged;
                verrorPrint(format, ap, info);
            }
            global.gaggedErrors++;
        }
        break;

    case ErrorKind.deprecation:
        if (global.params.useDeprecated == DiagnosticReporting.error)
            goto case ErrorKind.error;
        else if (global.params.useDeprecated == DiagnosticReporting.inform)
        {
            if (!global.gag)
            {
                global.deprecations++;
                if (global.params.v.errorLimit == 0 || global.deprecations <= global.params.v.errorLimit)
                {
                    info.headerColor = Classification.deprecation;
                    verrorPrint(format, ap, info);

                    // Hook: Generate SARIF report for this error
                    generateSarifReport(info.loc, format, ap, info.kind);
                }
            }
            else
            {
                global.gaggedWarnings++;
            }
        }
        break;

    case ErrorKind.warning:
        if (global.params.warnings != DiagnosticReporting.off)
        {
            if (!global.gag)
            {
                info.headerColor = Classification.warning;
                verrorPrint(format, ap, info);

                // Hook: Generate SARIF report for this error
                generateSarifReport(info.loc, format, ap, info.kind);

                if (global.params.warnings == DiagnosticReporting.error)
                    global.warnings++;
            }
            else
            {
                global.gaggedWarnings++;
            }
        }
        break;

    case ErrorKind.tip:
        if (!global.gag)
        {
            info.headerColor = Classification.tip;
            verrorPrint(format, ap, info);

            // Hook: Generate SARIF report for this error
            generateSarifReport(info.loc, format, ap, info.kind);
        }
        break;

    case ErrorKind.message:
        const p = info.loc.toChars();
        if (*p)
        {
            fprintf(stdout, "%s: ", p);
            mem.xfree(cast(void*)p);
        }
        OutBuffer tmp;
        tmp.vprintf(format, ap);
        fputs(tmp.peekChars(), stdout);
        fputc('\n', stdout);
        fflush(stdout);     // ensure it gets written out in case of compiler aborts

        // Hook: Generate SARIF report for this message
        generateSarifReport(info.loc, format, ap, info.kind);
        break;
    }
}
