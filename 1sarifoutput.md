# SARIF Template (Second Draft)

File- https://github.com/royalpinto007/d-drafts/blob/main/1sarif.d

## Running Unit Tests

To run the built-in unit tests, execute the following command:

```bash
$ dmd -unittest 1sarif.d && ./1sarif --unittest
```

**Output**:

```
1 modules passed unittests
```

## Generating Example JSON Output

To serialize and display example SARIF results, use the following command:

```bash
$ dmd 1sarif.d && ./1sarif
```

**Output**:

```json
{
  "invocation": {
    "executionSuccessful": true
  },
  "results": [
    {
      "location": {
        "artifactLocation": {
          "uri": "test.c"
        },
        "region": {
          "startColumn": 20,
          "startLine": 5
        }
      },
      "message": "Variable not initialized",
      "ruleId": "rule1",
      "suggestedFix": "Initialize the variable."
    },
    {
      "location": {
        "fullyQualifiedName": "fully.qualified.main",
        "name": "main"
      },
      "message": "Function not used",
      "ruleId": "rule2",
      "suggestedFix": "Remove the unused function."
    }
  ],
  "tool": {
    "name": "DMD",
    "version": "2.109.1"
  }
}
```

## Understanding

### Invocation Block:

- `"executionSuccessful": true`: Indicates that the analysis tool ran successfully. (false, whenever we find an error in a program)

## First Result Block:

- **Location**: Error at `test.c`, line 5, column 20.
- **Message**: "Variable not initialized."
- **Rule**: `rule1`.
- **Suggested Fix**: "Initialize the variable."

### Second Result Block:

- **Location**: Logical location in the `fully.qualified.main` function.
- **Message**: "Function not used."
- **Rule**: `rule2`.
- **Suggested Fix**: "Remove the unused function."

### Tool Block:

- Tool used: `DMD`, version `2.109.1`.
