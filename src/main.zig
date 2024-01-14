const std = @import("std");
const lexer = @import("lexer.zig");

const Lexer = lexer.Lexer;
const Token = lexer.Token;
const TokenKind = lexer.TokenKind;

const string = []const u8;

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
