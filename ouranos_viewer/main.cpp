#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <vector>
#include <string>
#include <algorithm>
#include <cmath>
#include <iostream>
#include <cerrno>
#include <cstdint>

#define PORT 8080
#define BUFFER_SIZE 1024

int SCREEN_WIDTH = 800;
int SCREEN_HEIGHT = 800;

#pragma pack(push, 1)
struct preSomatouranos
{
    uint16_t x;
    uint16_t y;
    float brightness;
};
#pragma pack(pop)
static_assert(sizeof(preSomatouranos) == 8, "Unexpected star record size");

struct Somatouranos
{
    Vector2 pos;
    std::string designation;
    float magnitude, radius, alpha;
};

struct Telescope
{
    double telescope_focal_length = 1000.0;
    double eyepiece_focal_length = 25.0;
    double eyepiece_afov = 52.0;
    double sensor_width = 11.3;
    double magnification;
    double tfov_degrees;
    double tfov_arcminutes;
    double max_angle_view;

    void init()
    {
        magnification = telescope_focal_length / eyepiece_focal_length;
        tfov_degrees = eyepiece_afov / magnification;
        tfov_arcminutes = tfov_degrees * 60.0;
        max_angle_view = 2 * std::atan(sensor_width / (2 * telescope_focal_length)) * 180 / PI;
    }
};

bool read_exact(int socket, char* buffer, size_t length)
{
    size_t bytes_read = 0;
    while (bytes_read < length) 
    {
        ssize_t result = read(socket, buffer + bytes_read, length - bytes_read);
        if (result < 0 && errno == EINTR)
            continue;
        if (result <= 0)
            return false;
            
        bytes_read += result;
    }
    return true;
}

struct Ouranos
{
    std::vector<Somatouranos> somas;
    Vector2 center = {(float)(SCREEN_WIDTH / 2), (float)(SCREEN_HEIGHT / 2)};
    float pixels_per_degree;
    float radius_degrees;
    float radius_pixels;

    void init(double tfov_degrees)
    {
        pixels_per_degree = static_cast<float>(std::min(SCREEN_WIDTH, SCREEN_HEIGHT) / tfov_degrees);
        radius_degrees = (float)(tfov_degrees / 2.0);
        radius_pixels = radius_degrees * pixels_per_degree;
        std::cout << "Radius degrees, pixels: " << radius_degrees << " " << radius_pixels << "\n";
    }
};

void ping()
{
    int server_fd, client_fd;
    struct sockaddr_in address;
    int opt = 1;
    socklen_t addrlen = sizeof(address);
    char buffer[BUFFER_SIZE] = {0};
    const char *response = "Hello from Linux POSIX TCP Server!";

    // 1. Create a TCP socket (AF_INET = IPv4, SOCK_STREAM = TCP)
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Forcefully attaching socket to the port 8080 to prevent "Address already in use" errors
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
        perror("setsockopt failed");
        exit(EXIT_FAILURE);
    }

    // Configure the address struct
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY; // Bind to all available network interfaces
    address.sin_port = htons(PORT);       // Convert port to network byte order

    // 2. Bind the socket to the network address and port
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("Bind failed");
        exit(EXIT_FAILURE);
    }

    // 3. Listen for incoming connections (Queue size = 3)
    if (listen(server_fd, 3) < 0) {
        perror("Listen failed");
        exit(EXIT_FAILURE);
    }

    printf("Server is listening on port %d...\n", PORT);

    // 4. Accept a connection (This blocks until a client connects)
    if ((client_fd = accept(server_fd, (struct sockaddr *)&address, &addrlen)) < 0) {
        perror("Accept failed");
        exit(EXIT_FAILURE);
    }

    // 5. Read data from the client socket and send a reply
    ssize_t valread = read(client_fd, buffer, BUFFER_SIZE - 1);
    if (valread > 0) {
        printf("Received from client: %s\n", buffer);
    }
    
    write(client_fd, response, strlen(response));
    printf("Response sent to client.\n");

    // 6. Clean up
    close(client_fd);
    close(server_fd);
}

int main() 
{
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Ouranos Viewer");
    Telescope t;
    t.init();

    Ouranos ouranos;
    ouranos.init(t.tfov_degrees);

    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        perror("socket");
        CloseWindow();
        return 1;
    }
    int opt = 1;
    sockaddr_in address{};
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    address.sin_port = htons(PORT);
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0 ||
        bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0 ||
        listen(server_fd, 3) < 0) {
        perror("Starting server");
        close(server_fd);
        CloseWindow();
        return 1;
    }

    std::cout << "Waiting for Lua client on port " << PORT << "..." << std::endl;
    int client_socket = accept(server_fd, nullptr, nullptr);
    if (client_socket < 0) {
        perror("accept");
        close(server_fd);
        CloseWindow();
        return 1;
    }

    // The client sends a little-endian uint32 count followed by 8-byte records.
    // This direct mapping assumes a little-endian host with 32-bit IEEE floats.
    uint32_t star_count = 0;
    constexpr uint32_t max_stars = 1000000;
    if (!read_exact(client_socket, reinterpret_cast<char*>(&star_count), sizeof(star_count)) ||
        star_count > max_stars) {
        std::cerr << "Invalid or incomplete star count.\n";
        close(client_socket);
        close(server_fd);
        CloseWindow();
        return 1;
    }

    std::vector<preSomatouranos> stars(star_count);
    if (!read_exact(client_socket, reinterpret_cast<char*>(stars.data()), stars.size() * sizeof(preSomatouranos))) {
        std::cerr << "Incomplete star data.\n";
        close(client_socket);
        close(server_fd);
        CloseWindow();
        return 1;
    }
    close(client_socket);
    close(server_fd);

    ouranos.somas.reserve(stars.size());
    for (const auto& star : stars) {
        if (!std::isfinite(star.brightness)) {
            std::cerr << "Invalid star brightness.\n";
            CloseWindow();
            return 1;
        }
        Somatouranos soma = {
            .pos = {static_cast<float>(star.x), static_cast<float>(star.y)},
            .designation = "",
            .magnitude = star.brightness,
            .radius = 5.0f,
            .alpha = std::clamp(star.brightness, 0.0f, 1.0f)
        };
        ouranos.somas.push_back(soma);
    }
    std::cout << "Received " << ouranos.somas.size() << " stars.\n";

    SetTargetFPS(60);

    while(!WindowShouldClose())
    {

        BeginDrawing();
        ClearBackground(BLACK);
        for (const auto& soma : ouranos.somas)
        {
            if (CheckCollisionPointCircle(soma.pos, ouranos.center, ouranos.radius_pixels))
                DrawCircleV(soma.pos, soma.radius, Fade(WHITE, soma.alpha));
        }
        EndDrawing();
    }

    CloseWindow();
    return 0;
}
