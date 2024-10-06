# SARIF Template (Third Draft)

File- https://github.com/royalpinto007/d-drafts/blob/main/2sarif.d

## Running Unit Tests

To run the built-in unit tests, execute the following command:

```bash
$ dmd -unittest 2sarif.d && ./2sarif --unittest
```

**Output**:

```
1 modules passed unittests
```

## Generating Example JSON Output

To serialize and display example SARIF results, use the following command with a specified source file:

```bash
$ dmd 2sarif.d && ./2sarif --sourceFile=test.d
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
      "ruleId": "DMD",
      "suggestedFix": "Initialize the variable or declare it."
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
- **Suggested Fix**: "Initialize the variable or declare it."

**Tool Block**:

- Tool used: `DMD`, version `2.109.1`.

## Added suggested fixes for these 8 programs:

### Example 1: Undefined Identifier (Variable Not Declared)

```d
// test.d
void main() {
    myVar = 5;  // Error: undefined identifier `myVar`
}
```

**Expected Error Message**: `Error: undefined identifier 'myVar'`  
**Suggested Fix**: "Initialize the variable or declare it."

---

### Example 2: Function Does Not Return a Value

```d
// test.d
int add(int a, int b) {
    // No return statement, but function expects a return
}
```

**Expected Error Message**: `Error: function 'add' does not return a value`  
**Suggested Fix**: "Ensure the function returns a value or use 'void' as the return type."

---

### Example 3: Type Mismatch

```d
// test.d
void main() {
    int a = "Hello";  // Error: type mismatch: cannot assign string to int
}
```

**Expected Error Message**: `Error: type mismatch: cannot assign string to int`  
**Suggested Fix**: "Check the types of the variables or use a cast if necessary."

---

### Example 4: No Property Error

```d
// test.d
struct MyStruct {
    int a;
}

void main() {
    MyStruct s;
    s.b = 10;  // Error: no property 'b' for type 'MyStruct'
}
```

**Expected Error Message**: `Error: no property 'b' for type 'MyStruct'`  
**Suggested Fix**: "Ensure the object has the specified property or method."

---

### Example 5: Cannot Implicitly Convert Type

```d
// test.d
void main() {
    int a = 3.14;  // Error: cannot implicitly convert expression 3.14 of type double to int
}
```

**Expected Error Message**: `Error: cannot implicitly convert expression 3.14 of type double to int`  
**Suggested Fix**: "Explicitly cast the value to the expected type."

---

### Example 6: Division by Zero

```d
// test.d
void main() {
    int a = 10 / 0;  // Error: division by zero
}
```

**Expected Error Message**: `Error: division by zero`  
**Suggested Fix**: "Avoid division by zero or handle the case where the denominator is zero."

---

### Example 7: Missing Semicolon

```d
// test.d
void main() {
    int a = 5  // Error: missing semicolon after declaration
}
```

**Expected Error Message**: `Error: found '}' instead of ';'`  
**Suggested Fix**: "Check for a missing semicolon after the previous statement."

---

### Example 8: Cannot Modify Immutable

```d
// test.d
void main() {
    immutable int a = 10;
    a = 20;  // Error: cannot modify immutable variable 'a'
}
```

**Expected Error Message**: `Error: cannot modify immutable variable 'a'`  
**Suggested Fix**: "Declare the variable as 'mutable' if it needs to be modified."

---
