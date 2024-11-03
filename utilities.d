import std.stdio;

string createRepeatedString(char c, size_t length) {
    string result;
    foreach (i; 0 .. length) {
        result ~= c;
    }
    return result;
}

string generateSquiggle(size_t start, size_t length) {
    return createRepeatedString(' ', start) ~ createRepeatedString('~', length);
}

string generateCaret(size_t position) {
    return createRepeatedString(' ', position) ~ "^";
}

void printErrorWithSquiggle(string codeLine, size_t column, size_t length) {
    writeln("Error: Missing or unexpected token");
    writeln(codeLine);
    writeln(generateSquiggle(column, length));
}

void printErrorWithCaret(string codeLine, size_t column) {
    writeln("Error: Unexpected token");
    writeln(codeLine);
    writeln(generateCaret(column));
}

void main() {
    writeln("Example 1: Missing Semicolon");
    string codeLine1 = "int x = 10";
    size_t errorColumn1 = 9;
    size_t errorLength1 = 2;
    printErrorWithSquiggle(codeLine1, errorColumn1, errorLength1);
    writeln();

    writeln("Example 2: Unexpected Token");
    string codeLine2 = "int x = ;";
    size_t errorColumn2 = 8;
    printErrorWithCaret(codeLine2, errorColumn2);
    writeln();

    writeln("Example 3: Unmatched Parenthesis");
    string codeLine3 = "if (x > 10 {";
    size_t errorColumn3 = 9;
    size_t errorLength3 = 1;
    printErrorWithSquiggle(codeLine3, errorColumn3, errorLength3);
    writeln();
}
