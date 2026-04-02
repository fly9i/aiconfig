use std::fs;
use std::io::{self, BufRead, Write};

use clap::{Parser, Subcommand};

const AGENTS_URL: &str = "https://raw.githubusercontent.com/fly9i/aiconfig/main/AGENTS.md";

#[cfg(unix)]
use std::os::unix::fs::symlink;

#[cfg(windows)]
fn symlink<P: AsRef<std::path::Path>, Q: AsRef<std::path::Path>>(
    _original: P,
    _link: Q,
) -> std::io::Result<()> {
    Ok(())
}

#[derive(Parser)]
#[command(name = "my", about = "Personal CLI tool")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Download AGENTS.md and symlink to CLAUDE.md
    Agents,
}

fn prompt_overwrite(path: &std::path::Path) -> bool {
    println!("文件 {} 已存在，是否覆盖？[y/N]", path.display());
    io::stdout().flush().ok();
    let mut input = String::new();
    io::stdin().lock().read_line(&mut input).ok();
    matches!(input.trim().to_lowercase().as_str(), "y" | "yes")
}

fn cmd_agents() -> Result<(), Box<dyn std::error::Error>> {
    let cwd = std::env::current_dir()?;
    let agents_path = cwd.join("AGENTS.md");
    let claude_path = cwd.join("CLAUDE.md");

    if agents_path.exists() && !prompt_overwrite(&agents_path) {
        println!("跳过下载");
        if !claude_path.exists() && claude_path.symlink_metadata().is_err() {
            symlink("AGENTS.md", &claude_path)?;
            println!("Symlink -> {} -> AGENTS.md", claude_path.display());
        }
        return Ok(());
    }

    println!("Downloading AGENTS.md from {}", AGENTS_URL);

    let content = reqwest::blocking::get(AGENTS_URL)?
        .error_for_status()?
        .text()?;
    fs::write(&agents_path, &content)?;
    println!("Saved -> {}", agents_path.display());

    if claude_path.exists() || claude_path.symlink_metadata().is_ok() {
        fs::remove_file(&claude_path)?;
    }
    symlink("AGENTS.md", &claude_path)?;
    println!("Symlink -> {} -> AGENTS.md", claude_path.display());

    Ok(())
}

fn main() {
    let cli = Cli::parse();
    if let Err(e) = match cli.command {
        Commands::Agents => cmd_agents(),
    } {
        eprintln!("Error: {e}");
        std::process::exit(1);
    }
}
