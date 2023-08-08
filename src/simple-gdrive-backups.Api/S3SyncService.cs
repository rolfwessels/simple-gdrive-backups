using Cronos;
using System;
using System.Diagnostics;
using System.Threading;

public class S3SyncService : BackgroundService
{
  private readonly ILogger<S3SyncService> _log;
  private string _bucket;
  private string _toFolder;
  private Truths _sourceOfTruth;
  private string _cron;

  enum Truths
  {
    Local, Remote
  }

  public S3SyncService(ILogger<S3SyncService> log)
  {
    _log = log;
  }

  private T ReadEnum<T>(string value) where T : struct, Enum
  {
    if (Enum.TryParse(ReadValue(value, "local"), true, out T outValue))
    {
      return outValue;
    }
    _log.LogWarning("Could not determine source of truth, please set the `{value}` environment variable to {allowed}.", value, string.Join(", ", Enum.GetValues<T>()));
    return Enum.GetValues<T>().First();
  }

  private string ReadValue(string name, string? defaultValue = null)
  {
    return Environment.GetEnvironmentVariable(name) ?? defaultValue ?? throw new Exception($"Please set the {name} environment variable.");
  }

  protected override async Task ExecuteAsync(CancellationToken stoppingToken)
  {

    try
    {

      _bucket = ReadValue("S3_BUCKET");
      _toFolder = ReadValue("MAPPED_FOLDER", "/data");
      _sourceOfTruth = ReadEnum<Truths>("SOURCE_OF_TRUTH");
      _cron = ReadValue("CRON", "* 1 * * *");

      var isEmpty = !Directory.GetFiles(_toFolder).Any();
      if (isEmpty)
      {
        _log.LogInformation("Folder {_toFolder} is empty. Initializing folder from S3 .", _toFolder);
        await Execute("aws", $"s3 sync {_bucket} {_toFolder}", stoppingToken);
      }

      while (!stoppingToken.IsCancellationRequested)
      {
        await ExecuteTimedSync(stoppingToken);
        var expression = CronExpression.Parse(_cron);
        var nextUtc = expression.GetNextOccurrence(DateTime.UtcNow)!;
        var millisecondsDelay = nextUtc - DateTime.Now;
        _log.LogInformation("Next run at {nextUtc} in ({millisecondsDelay})", nextUtc.Value.ToLocalTime(), millisecondsDelay.ToString());
        await Task.Delay(millisecondsDelay ?? TimeSpan.FromHours(1), stoppingToken);
      }
    }
    catch (Exception e)
    {
      _log.LogError(e, "Failed to sync");
      throw;
    }
  }

  private async Task ExecuteTimedSync(CancellationToken stoppingToken)
  {

    switch (_sourceOfTruth)
    {
      case Truths.Remote:
        await Execute("aws", $"s3 sync {_bucket} {_toFolder} --delete", stoppingToken);
        break;
      case Truths.Local:
        await Execute("aws", $"s3 sync {_toFolder} {_bucket} --delete", stoppingToken);
        break;
    }
  }

  private async Task Execute(string file, string? arguments, CancellationToken cancellationToken)
  {
    _log.LogInformation("> {file} {arguments}", file, arguments);
    try
    {
      var process = new Process();
      var processStartInfo = new ProcessStartInfo()
      {
        WindowStyle = ProcessWindowStyle.Hidden,
        FileName = file,
        Arguments = arguments,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false
      };
      process.StartInfo = processStartInfo;
      process.Start();
      var readToEndAsync = process.StandardError.ReadToEndAsync(cancellationToken);
      var toEndAsync = process.StandardOutput.ReadToEndAsync(cancellationToken);
      var error = await readToEndAsync;
      var output = await toEndAsync;
      if (!string.IsNullOrEmpty(error))
      {
        _log.LogError(output);
      }
      if (!string.IsNullOrEmpty(output)) _log.LogInformation(output);
    }
    catch (Exception ex)
    {
      _log.LogError(ex.Message, ex);
      throw;
    }
  }

  public async Task Sync()
  {
    await ExecuteTimedSync(CancellationToken.None);
  }
}
