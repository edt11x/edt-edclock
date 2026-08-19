pub fn format_bytes(bytes: u64) -> String {
    const UNITS: &[&str] = &["B", "K", "M", "G", "T"];
    let mut size = bytes as f64;
    let mut unit_idx = 0;
    while size >= 1024.0 && unit_idx < UNITS.len() - 1 {
        size /= 1024.0;
        unit_idx += 1;
    }
    if size < 10.0 {
        format!("{:.1}{}", size, UNITS[unit_idx])
    } else {
        format!("{:.0}{}", size, UNITS[unit_idx])
    }
}

/// Formats a usage line. `total == 0` is the "old / missing stats" case.
pub fn format_usage(total: u64, available: u64) -> String {
    if total == 0 {
        return "Disk usage unavailable".to_string();
    }
    let used = total.saturating_sub(available);
    let used_pct = (used as f64 / total as f64 * 100.0) as i32;
    format!(
        "~ {} free of {} ({}% used)",
        format_bytes(available),
        format_bytes(total),
        used_pct
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn format_bytes_picks_unit() {
        assert_eq!(format_bytes(0), "0.0B");
        assert_eq!(format_bytes(512), "512B");
        assert_eq!(format_bytes(1536), "1.5K");
        assert_eq!(format_bytes(10 * 1024), "10K");
        assert_eq!(format_bytes(1024 * 1024 * 1024), "1.0G");
    }

    #[test]
    fn missing_total_does_not_panic() {
        assert_eq!(format_usage(0, 0), "Disk usage unavailable");
        assert_eq!(format_usage(0, 99), "Disk usage unavailable");
    }

    #[test]
    fn usage_line_includes_percent() {
        let line = format_usage(1000, 250);
        assert!(line.contains("250B"));
        assert!(line.contains("75% used"));
    }
}
