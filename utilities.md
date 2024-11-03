## Utilities

File- [utilities.d](https://github.com/royalpinto007/d-drafts/blob/main/utilities.d)

### Example 1: Missing Semicolon

In this case, the code line is:

```d
int x = 10
```

The semicolon at the end of the statement is missing.

#### Current DMD Output

DMD might produce a generic message without a precise indicator:

```plaintext
Error: Missing or unexpected token
```

This message lacks detail on the specific location of the missing token, making it harder for developers to pinpoint the exact issue.

#### Rust Output

Rust provides a detailed error message and caret, making it easier to locate the problem:

```plaintext
error: expected one of `;`, `}`, or `,`, found end of line
 --> <source>:3:11
  |
3 | int x = 10
  |           ^ expected one of `;`, `}`, or `,` here
```

Rust’s message indicates exactly where the missing token should go with a caret (`^`), and suggests possible fixes.

#### GCC Output

GCC similarly gives precise feedback:

```plaintext
<source>: In function ‘int main()’:
<source>:3:10: error: expected ‘;’ before ‘}’ token
    3 | int x = 10
      |          ^ expected ‘;’ here
```

GCC pinpoints the exact location where the semicolon is missing, along with an explanatory message.

#### Enhanced DMD Output

With the squiggle approach, DMD could highlight the missing token’s location more visually:

```plaintext
Example 1: Missing Semicolon
Error: Missing or unexpected token
int x = 10
          ~~
```

The squiggle (`~~`) here clearly indicates where the semicolon should be, making it visually intuitive for the developer.

---

### Example 2: Unexpected Token

Here, the code line is:

```d
int x = ;
```

There’s an unexpected semicolon after the assignment operator.

#### Current DMD Output

DMD might simply say:

```plaintext
Error: Unexpected token
```

This generic message does not show exactly where the unexpected token (`;`) appears.

#### Rust Output

Rust would provide a more precise message:

```plaintext
error: expected expression, found `;`
 --> <source>:3:10
  |
3 | int x = ;
  |          ^ expected expression here
```

Rust not only points to the location with a caret but also clarifies that an expression was expected instead of the `;`.

#### GCC Output

GCC provides similar clarity:

```plaintext
<source>: In function ‘int main()’:
<source>:3:8: error: expected expression before ‘;’ token
    3 | int x = ;
      |        ^
```

GCC also uses a caret (`^`) to mark the exact spot of the unexpected semicolon.

#### Enhanced DMD Output

With a caret indicator, DMD could make this error more visible:

```plaintext
Example 2: Unexpected Token
Error: Unexpected token
int x = ;
        ^
```

The caret (`^`) under the semicolon (`;`) shows the developer exactly where the unexpected token occurs, improving error comprehension.

---

### Example 3: Unmatched Parenthesis

In this case, the code line is:

```d
if (x > 10 {
```

An opening parenthesis is left unmatched.

#### Current DMD Output

DMD might report a generic message:

```plaintext
Error: Missing or unexpected token
```

Again, this message alone does not indicate the precise issue or location, leaving it to the developer to find the unmatched parenthesis.

#### Rust Output

Rust provides a more detailed message with a specific location:

```plaintext
error: expected `)`, found `{`
 --> <source>:3:13
  |
3 | if (x > 10 {
  |             ^ expected `)` to match this `{`
```

Rust’s error message not only specifies that a closing parenthesis is missing but also indicates the exact location.

#### GCC Output

GCC’s output would look something like this:

```plaintext
<source>: In function ‘int main()’:
<source>:3:12: error: expected ‘)’ before ‘{’ token
    3 | if (x > 10 {
      |            ^
```

GCC uses a caret (`^`) to mark the unmatched opening parenthesis, along with an explanatory message.

#### Enhanced DMD Output

Using a squiggle, DMD could highlight the unmatched opening parenthesis in a similar way:

```plaintext
Example 3: Unmatched Parenthesis
Error: Missing or unexpected token
if (x > 10 {
           ~
```

The squiggle (`~`) directly under the unmatched `{` makes it clear where the error is, helping developers quickly understand the issue.

___