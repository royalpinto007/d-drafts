# SARIF Template

File- https://github.com/royalpinto007/d-drafts/blob/main/sarif.d 

## Running Unit Tests

To run the built-in unit tests, execute the following command:

```bash
$ dmd -unittest sarif.d && ./sarif --unittest
```

**Output:**
```
1 modules passed unittests
```

## Generating Example JSON Output

To serialize and display example `PhysicalLocation` and `LogicalLocation` objects, use the following command:

```bash
$ dmd sarif.d && ./sarif
```

**Output:**
```json
{
    "location": {
        "artifactLocation": {
            "uri": "file.c"
        },
        "region": {
            "startColumn": 10,
            "startLine": 1
        }
    },
    "ruleId": "rule1"
}
{
    "location": {
        "fullyQualifiedName": "fully.qualified.main",
        "name": "main"
    },
    "ruleId": "rule2"
}
```

## Understanding

### First JSON Block:
Represents a result for `rule1`, indicating that the rule was violated at `file.c`, line 1, column 10.

- `"artifactLocation"`: Specifies the file (`file.c`) where the violation occurred.
- `"region"`: Specifies the exact line (`1`) and column (`10`).

### Second JSON Block:
Represents a result for `rule2`, indicating a rule violation at a logical location in the code.

- `"fullyQualifiedName"`: The fully qualified name of the function (`fully.qualified.main`).
- `"name"`: The simple name of the function (`main`).
