### Documentation: `physicalLocation` vs. `logicalLocations` in SARIF Output

---

In SARIF (Static Analysis Results Interchange Format), `physicalLocation` and `logicalLocations` provide crucial information about where errors or warnings occur within the source code. Understanding the differences between them helps developers diagnose issues more efficiently, especially when integrating SARIF with the compiler's diagnostic outputs.

This document explains both fields and highlights the differences between them based on real-world examples using GCC and Clang SARIF outputs.

---

#### `physicalLocation`

- **Purpose**: `physicalLocation` provides the exact **physical position** of an issue in the source code.
- **What it contains**:
  - The **file** where the issue is found.
  - The specific **line number** and **column** within the file.
  - It may also include snippets of the problematic code, helping developers see the error in context.
- **Importance**:
  - This field is essential for directly locating the error within a codebase, making it the foundation of any static analysis report.
  - It is **always included** in SARIF results because without it, there would be no way to pinpoint where the issue occurs in the source files.

##### Example:

```json
{
  "artifactLocation": {
    "uri": "test.c",
    "uriBaseId": "PWD"
  },
  "region": {
    "startLine": 5,
    "startColumn": 14,
    "endColumn": 15
  }
}
```

- In this example, the error occurs in `test.c` on **line 5**, starting at **column 14**.

---

#### `logicalLocations`

- **Purpose**: `logicalLocations` provides context on the **logical structure** within the code (e.g., the function, method, class, or namespace) where the issue occurred.
- **What it contains**:
  - The **name of the function** or **method** involved.
  - The **fully qualified name** that provides the complete context of the function, class, or module.
  - Information about whether the location represents a **function**, **class**, **module**, or some other logical unit.
- **Importance**:
  - This information is valuable for understanding **which part** of the software architecture is affected. In complex systems, identifying the method or class where an error occurs is crucial for debugging.
  - `logicalLocations` is **optional**, meaning compilers may or may not include it depending on how they implement SARIF output.

##### Example:

```json
{
  "name": "main",
  "fullyQualifiedName": "main",
  "decoratedName": "main",
  "kind": "function"
}
```

- This example shows that the error is within the function `main`.

---

### Differences Between `physicalLocation` and `logicalLocations`

| **Aspect**             | **physicalLocation**                                                                          | **logicalLocations**                                                                                                    |
| ---------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Definition**         | Specifies the **physical** location of the error in the source code (file, line, and column). | Describes the **logical** context (e.g., function, class, or module) where the error occurred.                          |
| **Inclusion in SARIF** | **Always** included in SARIF outputs.                                                         | **Optional** in SARIF outputs; may or may not be included.                                                              |
| **Purpose**            | Helps identify **exact** location of the error in the file.                                   | Provides **contextual** information about where the error occurs within the code's structure (e.g., function or class). |
| **Use Case**           | Used for navigating directly to the error in the source file.                                 | Helps understand which part of the codebase (function, class, etc.) is affected.                                        |
| **Compiler Behavior**  | Both GCC and Clang include `physicalLocation`.                                                | GCC includes `logicalLocations`; Clang does not.                                                                        |

---

### Practical Application for DMD Compiler Developers

- **When to Use**:
  - Always include **`physicalLocation`** in the SARIF output as it is required for pinpointing the error within the source code.
  - Consider including **`logicalLocations`** when the error occurs within specific functions, classes, or other logical structures. This provides additional context to developers and can be especially useful in large, complex projects.
- **Benefits**:

  - **physicalLocation** allows developers to quickly jump to the exact point in the file where the error occurred.
  - **logicalLocations** adds clarity by showing which part of the architecture (such as functions or classes) is impacted, making debugging more efficient.

- **Current Behavior in GCC and Clang**:
  - **GCC**: Includes both `physicalLocation` and `logicalLocations`, providing detailed error location and context.
  - **Clang**: Only includes `physicalLocation`, focusing on the direct location of the error.
  - SARIF Output Analysis can be found [here](https://docs.google.com/document/d/1Hl0Zbmr93XpapSubd8tLOIIunNfsBFM-DJjWj0BoaJ4/edit?usp=sharing).

---
