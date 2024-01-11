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

    pub fn format(self: Token, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt; // autofix
        _ = options; // autofix
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

    pub fn nextToken(lex: *Lexer) Token {
        lex.eatWhitespace();
        var tok = Token{};
        switch (lex.ch) {
            '(', ')' => {
                tok.kind = .Syntax;
                tok.value = lex.currStr();
            },
            0 => tok.kind = .EOF,
            else => {},
        }
        tok.location = lex.cursor;

        lex.readChar();

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
};

// main loop

pub fn main() !void {
    const prompt = ">> ";
    var reader = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;
    std.debug.print("zsch v0.1 - 2023\n", .{});
    std.debug.print("{s}", .{prompt});

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var lex = Lexer.init(line);
        while (lex.ch != 0) {
            const token = lex.nextToken();

            std.debug.print("{}\n", .{token});
        }

        std.debug.print("{s}", .{prompt});
    }
}
