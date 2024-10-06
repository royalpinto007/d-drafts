# SARIF Template (Fourth Draft)

File- https://github.com/royalpinto007/d-drafts/blob/main/3sarif.d

This version of the template focuses solely on identifying the error without providing any suggested fixes, keeping the structure straightforward.

## Running Unit Tests
To run the built-in unit tests, execute the following command:

```bash
$ dmd -unittest 3sarif.d && ./3sarif --unittest
```

**Output**:
```
1 modules passed unittests
```

## Generating Example JSON Output
To serialize and display example SARIF results, use the following command with a specified source file:

```bash
$ dmd 3sarif.d && ./3sarif --sourceFile=test.d
```

**Output**:
```json
{
    "invocation": {
        "executionSuccessful": false
    },
    "results": [
        {
            "location": {
                "artifactLocation": {
                    "uri": "test.d"
                },
                "region": {
                    "startColumn": 0,
                    "startLine": 2
                }
            },
            "message": "Error: undefined identifier `myVar`",
            "ruleId": "DMD"
        }
    ],
    "tool": {
        "name": "DMD",
        "version": "2.109.1"
    }
}
```

### Understanding
**Invocation Block**:
- `"executionSuccessful": false`: Indicates that the analysis tool encountered an error during execution.

**Result Block**:
- **Location**: Error found at `test.d`, line 2, column 0.
- **Message**: "Error: undefined identifier `myVar`."
- **Rule**: `DMD` rule triggered this error.

**Tool Block**:
- Tool used: `DMD`, version `2.109.1`.
