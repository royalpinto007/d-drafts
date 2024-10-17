### Test File: `sarif_test.d`

```
/*
TEST_OUTPUT:
---
fail_compilation/sarif_test.d(34): Error: undefined identifier `x`
{
  "invocation": {
    "executionSuccessful": false
  },
  "results": [
    {
      "location": {
        "artifactLocation": {
          "uri": "$p:sarif_test\\.d$"
        },
        "region": {
          "startLine": 34,
          "startColumn": 5
        }
      },
      "message": "undefined identifier `x`",
      "ruleId": "DMD"
    }
  ],
  "tool": {
    "name": "DMD",
    "version": "$r:v2\\..*$"
  }
}
---
*/
// REQUIRED_ARGS: --sarif

void main() {
    x = 5; // Undefined variable to trigger the error
}
```

---

### Logs from Running the Test:

```
~/d-build-source/dmd/compiler/test$ rdmd run.d fail_compilation/sarif_test.d BUILD=debug --compiler-flags="--sarif"
 ... fail_compilation/sarif_test.d  -verrors=0 --sarif  -fPIC ()
==============================
Test 'fail_compilation/sarif_test.d' failed. The logged output:
/home/royalpinto007/d-build-source/dmd/generated/linux/debug/64/dmd -conf= -m64 -Ifail_compilation -verrors=0 --sarif  -fPIC  -od/home/royalpinto007/d-build-source/dmd/compiler/test/test_results/fail_compilation/d -of/home/royalpinto007/d-build-source/dmd/compiler/test/test_results/fail_compilation/d/sarif_test_0.o  -c fail_compilation/sarif_test.d 
fail_compilation/sarif_test.d(34): Error: undefined identifier `x`
{
  "invocation": {
    "executionSuccessful": false
  },
  "results": [
    {
      "location": {
        "artifactLocation": {
          "uri": "file:///home/royalpinto007/d-build-source/dmd/compiler/test/fail_compilation/sarif_test.d"
        },
        "region": {
          "startLine": 34,
          "startColumn": 5
        }
      },
      "message": "undefined identifier `x`",
      "ruleId": "DMD"
    }
  ],
  "tool": {
    "name": "DMD",
    "version": "v2.110.0-beta.1-324-gab8582b70f-dirty"
  }
}

==============================
Test 'fail_compilation/sarif_test.d' failed: 
expected:
----
fail_compilation/sarif_test.d(34): Error: undefined identifier `x`
{
  "invocation": {
    "executionSuccessful": false
  },
  "results": [
    {
      "location": {
        "artifactLocation": {
          "uri": "$p:sarif_test\\.d$"
        },
        "region": {
          "startLine": 34,
          "startColumn": 5
        }
      },
      "message": "undefined identifier `x`",
      "ruleId": "DMD"
    }
  ],
  "tool": {
    "name": "DMD",
    "version": "$r:v2\\..*$"
  }
}
----
actual:
----
fail_compilation/sarif_test.d(34): Error: undefined identifier `x`
{
  "invocation": {
    "executionSuccessful": false
  },
  "results": [
    {
      "location": {
        "artifactLocation": {
          "uri": "file:///home/royalpinto007/d-build-source/dmd/compiler/test/fail_compilation/sarif_test.d"
        },
        "region": {
          "startLine": 34,
          "startColumn": 5
        }
      },
      "message": "undefined identifier `x`",
      "ruleId": "DMD"
    }
  ],
  "tool": {
    "name": "DMD",
    "version": "v2.110.0-beta.1-324-gab8582b70f-dirty"
  }
}
----
diff:
----
     {
       "location": {
         "artifactLocation": {
-          "uri": "$p:sarif_test\\.d$"
+          "uri": "file:///home/royalpinto007/d-build-source/dmd/compiler/test/fail_compilation/sarif_test.d"
         },
         "region": {
           "startLine": 34,
@@ -20,6 +20,6 @@ fail_compilation/sarif_test.d(34): Error
   ],
   "tool": {
     "name": "DMD",
-    "version": "$r:v2\\..*$"
+    "version": "v2.110.0-beta.1-324-gab8582b70f-dirty"
   }
 }
----

>>> TARGET FAILED: fail_compilation/sarif_test.d
FAILED targets:
- fail_compilation/sarif_test.d
```

---