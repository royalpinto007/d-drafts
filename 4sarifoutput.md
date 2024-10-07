# SARIF Template (Fifth Draft)  

File: https://github.com/royalpinto007/d-drafts/blob/main/4sarif.d

## Running Unit Tests
To run the built-in unit tests, execute the following command:

```bash
$ dmd -unittest 4sarif.d && ./4sarif --unittest
```

**Output**:
```
1 modules passed unittests
```

## Generating Example JSON Output
To serialize and display example SARIF results, use the following command with a specified source file:

```bash
$ dmd 4sarif.d && ./4sarif --sourceFile=test.d
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

### Comment for Fifth Draft:
In this draft, I achieved the SARIF output by **manually handling the data structures and string manipulations** without utilizing **Phobos utilities**. I focused more on using **basic D constructs** to handle operations such as string manipulation, error capturing, and region/location management to ensure full compatibility with DMD requirements.

