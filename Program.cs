using Microsoft.EntityFrameworkCore;
using Reposteria.DB;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configurar DbContext con MySQL y lazy loading
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(
        SQLConfig.ObtenerConnectionString(),
        ServerVersion.AutoDetect(SQLConfig.ObtenerConnectionString())
    );
    // Habilitar lazy loading con proxies
    options.UseLazyLoadingProxies();
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
