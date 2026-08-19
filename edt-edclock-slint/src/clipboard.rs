/// Same preset as `edt-edclock-windows` (`MainWindow.xaml.cs`).
pub const CLIPBOARD_PHRASE: &str = "iShouldaBoughtAServerTech!";

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn phrase_matches_windows_clock() {
        assert_eq!(CLIPBOARD_PHRASE, "iShouldaBoughtAServerTech!");
        assert!(!CLIPBOARD_PHRASE.is_empty());
    }
}
