pub mod calendar;
pub mod cli;
pub mod clipboard;
pub mod disk;

pub const VERSION: &str = env!("CARGO_PKG_VERSION");
pub const APP_NAME: &str = "edt-edclock-slint";

pub fn window_title() -> String {
    format!("edt-edclock (Slint) v{VERSION}")
}
