const std = @import("std");
const net = std.net;
const UUID = @import("uuid.zig").UUID;
const mem = std.mem;

const Client = struct {
    addr: net.Ip4Address,
    name: [64]u8,
};
const Message = struct {
    content: []const u8,
    from: *Client,
    created: usize, // The message sent to server by client
    sent: usize, // The message delivered to all clients
    done: bool, // Message sending process is finished
    id: UUID, // Random message id
};
const ServerConfig = struct {
    max_user: usize,
    ip: [4]u8,
    port: u16,
    pub fn default() ServerConfig {
        return ServerConfig{ .max_user = 32, .ip = .{ 0, 0, 0, 0 }, .port = 5555 };
    }
};

const Server = struct {
    allocator: std.mem,
    _server: net.Address, // why tf they renamed it to adress
    addr: [4]u8,
    port: u16,
    config: ServerConfig,
    clients: std.ArrayList(*Client),
    const Self = @This();
    pub fn init(allocator: mem.Allocator, config: ?ServerConfig) !*Server {
        var self = try allocator.create(@This());
        self.allocator = allocator;
        self.config = config orelse ServerConfig.default();
        self.addr = self.config.ip;
        self.port = self.config.port;
        self._server = net.Address.initIp4(self.addr, self.port);

        // Init clients
        const clients = std.ArrayList(*Client).init(self.allocator);
        self.clients = clients;
        return self;
    }
    pub fn mainloop_handler() void {
        mainloop() catch |err| {
            std.debug.print("Error happened in mainloop execution: {any}", .{err});
        };
    }
    pub fn mainloop() !void {
        std.debug.print("Mainloop TODO!\n", .{});
    }
    pub fn start(self: *Self) !void {
        const listen_config = net.Address.ListenOptions{ .reuse_address = true, .reuse_port = true };
        try self._server.listen(listen_config);
        std.debug.print("Server has been started!\n", .{});
        while (true) {
            mainloop_handler(); // Execute mainloop with handler
            // !TODO
            // Implement threads
        }
    }
    // Send message to a channel
    pub fn send_message(self: *Self, message: []const u8, client: *Client) !void {
        
    }
    // Refuse connection for some reason
    pub fn refuse_connection(self: *Self, message: []const u8, client: *Client) !void {
        self.send_message()
    }
    pub fn approve_connection(self: *Self, client: *Client) !void {
        self.add_user(client);
    }
    pub fn add_user(self: *Self, client: *Client) !void {
        if (self.clients.items.len >= self.config.max_user) {
            const refuse_message = "USER LIMIT REACHED";
            refuse_connection(
                refuse_message,
            );
        }
        try self.clients.append(client);
    }
};
