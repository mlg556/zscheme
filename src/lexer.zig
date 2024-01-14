const std = @import("std");

const string = []const u8;

pub const TokenKind = enum {
    /// "(" or ")"
    Syntax,
    /// "1234"
    Integer,
    /// "+", "define"
    Identifier,
    /// illegal token
    Illegal,
    /// end of file
    EOF,
};

pub const Token = struct {
    /// kind/type of token
    kind: TokenKind = .Illegal,
    /// its value
    value: string = "",
    /// location in source line
    location: u32 = 0,

    pub fn format(self: Token, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        return std.fmt.format(writer, "{d} {s}[{s}]", .{ self.location, @tagName(self.kind), self.value });
    }
};

/// Main Lexer struct.
pub const Lexer = struct {
    /// input string line.
    input: string,
    /// current cursor in input (points to current char)
    cursor: u32 = 0,
    /// current reading cursor in input (after current char)
    next_cursor: u32 = 0,
    /// current char under examination
    ch: u8 = 0,

    /// initializes and returns a Lexer.
    pub fn init(input: string) Lexer {
        var lex = Lexer{ .input = input };
        lex.readChar();
        return lex;
    }

    /// gives us the next character and advance our cursor in the input string.
    fn readChar(lex: *Lexer) void {
        if (lex.next_cursor >= lex.input.len) {
            lex.ch = 0;
        } else {
            lex.ch = lex.input[lex.next_cursor];
        }

        lex.cursor = lex.next_cursor;
        lex.next_cursor += 1;
    }

    fn readNumber(lex: *Lexer) string {
        // TODO: integrate std.fmt.ParseInt
        const cur = lex.cursor;

        while (isDigit(lex.ch)) {
            lex.readChar();
        }

        return lex.input[cur..lex.cursor];
    }

    fn isDigit(ch: u8) bool {
        return std.ascii.isDigit(ch);
    }

    pub fn nextToken(lex: *Lexer) Token {
        lex.eatWhitespace();
        var tok = Token{};
        switch (lex.ch) {
            '(', ')' => {
                tok.kind = .Syntax;
                tok.value = lex.currStr();
                // explicity increment
                lex.readChar();
            },

            '0'...'9' => {
                tok.kind = .Integer;
                tok.value = lex.readNumber();
            },

            0 => tok.kind = .EOF,
            else => {
                // lets assume its identifier
                tok.kind = .Identifier;
                tok.value = lex.readIdentifier();
            },
        }

        // save cursor as token location for every case
        tok.location = lex.cursor;

        return tok;
    }

    pub fn currStr(lex: *Lexer) string {
        return lex.input[lex.cursor .. lex.cursor + 1];
    }

    fn eatWhitespace(lex: *Lexer) void {
        while (std.ascii.isWhitespace(lex.ch)) {
            lex.readChar();
        }
    }

    /// every non-space printable character can be used in identifiers.
    fn isIdent(ch: u8) bool {
        return std.ascii.isPrint(ch) and !std.ascii.isWhitespace(ch);
    }

    /// reads in an identifier and advances the lexer’s positions until it encounters a non-letter-character
    fn readIdentifier(lex: *Lexer) string {
        const cur = lex.cursor;

        while (isIdent(lex.ch)) {
            lex.readChar();
        }

        return lex.input[cur..lex.cursor];
    }
};
