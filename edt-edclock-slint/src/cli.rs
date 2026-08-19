use crate::{window_title, APP_NAME, VERSION};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Action {
    Run,
    Help,
    Version,
    Unknown(String),
}

pub fn parse_args<I, S>(args: I) -> Action
where
    I: IntoIterator<Item = S>,
    S: AsRef<str>,
{
    let mut iter = args.into_iter();
    let _argv0 = iter.next();
    match iter.next().as_ref().map(|s| s.as_ref()) {
        None => Action::Run,
        Some("-h") | Some("--help") | Some("-?") => Action::Help,
        Some("-V") | Some("--version") | Some("-v") => Action::Version,
        Some(other) if other.starts_with('-') => Action::Unknown(other.to_string()),
        Some(_) => Action::Run,
    }
}

pub fn help_text() -> String {
    format!(
        "\
{title}
Ultra-compact digital clock and calendar.

Usage: {name} [OPTIONS]

Options:
  -h, --help     Show this help and exit
  -V, --version  Show version and exit
",
        title = window_title(),
        name = APP_NAME,
    )
}

pub fn version_text() -> String {
    format!("{APP_NAME} {VERSION}")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn default_is_run() {
        assert_eq!(parse_args(["edt-edclock-slint"]), Action::Run);
    }

    #[test]
    fn help_and_version_flags() {
        assert_eq!(parse_args(["app", "--help"]), Action::Help);
        assert_eq!(parse_args(["app", "-h"]), Action::Help);
        assert_eq!(parse_args(["app", "--version"]), Action::Version);
        assert_eq!(parse_args(["app", "-V"]), Action::Version);
    }

    #[test]
    fn unknown_dash_flag() {
        match parse_args(["app", "--bogus"]) {
            Action::Unknown(s) => assert_eq!(s, "--bogus"),
            other => panic!("expected Unknown, got {other:?}"),
        }
    }

    #[test]
    fn help_text_includes_version() {
        let text = help_text();
        assert!(text.contains(VERSION));
        assert!(text.contains("--version"));
        assert!(text.contains("--help"));
    }

    #[test]
    fn version_text_includes_crate_version() {
        assert!(version_text().contains(VERSION));
    }
}
