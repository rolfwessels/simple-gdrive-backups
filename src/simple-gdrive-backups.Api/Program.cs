var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAuthentication();
builder.Services.AddSingleton<S3SyncService>();
builder.Services.AddHostedService<S3SyncService>();
var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/", () =>   $"Welcome to Simple-gdrive-backups {System.Reflection.Assembly.GetEntryAssembly()!.GetName().Version}");
app.MapGet("/sync", async (S3SyncService service,ILogger<Program> logger) =>
{
  try
  {
    await service.Sync();
    return "Done";
  }
  catch (Exception e)
  {
    logger.LogError(e, "Failed to sync {message},", e.Message);
    return "Nope!";
  }
});
app.Run();
