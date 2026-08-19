use chrono::{Datelike, NaiveDate};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DayCell {
    pub day: u32,
    pub is_today: bool,
    pub is_weekend: bool,
    pub is_other_month: bool,
}

pub fn days_in_month(year: i32, month: u32) -> u32 {
    let (ny, nm) = if month == 12 {
        (year + 1, 1)
    } else {
        (year, month + 1)
    };
    NaiveDate::from_ymd_opt(ny, nm, 1)
        .unwrap()
        .signed_duration_since(NaiveDate::from_ymd_opt(year, month, 1).unwrap())
        .num_days() as u32
}

pub fn prev_month(year: i32, month: u32) -> (i32, u32) {
    if month == 1 {
        (year - 1, 12)
    } else {
        (year, month - 1)
    }
}

pub fn next_month(year: i32, month: u32) -> (i32, u32) {
    if month == 12 {
        (year + 1, 1)
    } else {
        (year, month + 1)
    }
}

/// Six-week (42-cell) calendar grid. `today` is injected so tests are deterministic.
pub fn calendar_cells(year: i32, month: u32, today: NaiveDate) -> Vec<DayCell> {
    let first = NaiveDate::from_ymd_opt(year, month, 1).unwrap();
    let weekday_of_first = first.weekday().num_days_from_sunday();

    let mut days = Vec::with_capacity(42);

    let (py, pm) = prev_month(year, month);
    let days_in_prev = days_in_month(py, pm);
    for i in (0..weekday_of_first).rev() {
        let d = days_in_prev - i;
        days.push(DayCell {
            day: d,
            is_today: false,
            is_weekend: false,
            is_other_month: true,
        });
    }

    let dim = days_in_month(year, month);
    for d in 1..=dim {
        let date = NaiveDate::from_ymd_opt(year, month, d).unwrap();
        let wd = date.weekday().num_days_from_sunday();
        days.push(DayCell {
            day: d,
            is_today: date == today,
            is_weekend: wd == 0 || wd == 6,
            is_other_month: false,
        });
    }

    let mut d = 1;
    while days.len() < 42 {
        days.push(DayCell {
            day: d,
            is_today: false,
            is_weekend: false,
            is_other_month: true,
        });
        d += 1;
    }

    days
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn days_in_month_handles_leap_and_common_february() {
        assert_eq!(days_in_month(2024, 2), 29);
        assert_eq!(days_in_month(2023, 2), 28);
        assert_eq!(days_in_month(2026, 1), 31);
        assert_eq!(days_in_month(2026, 12), 31);
    }

    #[test]
    fn month_navigation_wraps_the_year() {
        assert_eq!(prev_month(2026, 1), (2025, 12));
        assert_eq!(next_month(2025, 12), (2026, 1));
        assert_eq!(prev_month(2026, 6), (2026, 5));
        assert_eq!(next_month(2026, 6), (2026, 7));
    }

    #[test]
    fn grid_is_always_42_cells() {
        let today = NaiveDate::from_ymd_opt(2026, 8, 19).unwrap();
        for month in 1..=12 {
            assert_eq!(calendar_cells(2026, month, today).len(), 42);
        }
    }

    #[test]
    fn today_flag_only_on_matching_current_month_day() {
        let today = NaiveDate::from_ymd_opt(2026, 1, 15).unwrap();
        let cells = calendar_cells(2026, 1, today);
        let hits: Vec<_> = cells.iter().filter(|c| c.is_today).collect();
        assert_eq!(hits.len(), 1);
        assert_eq!(hits[0].day, 15);
        assert!(!hits[0].is_other_month);
    }

    #[test]
    fn today_in_another_month_does_not_highlight() {
        let today = NaiveDate::from_ymd_opt(2026, 1, 15).unwrap();
        let cells = calendar_cells(2026, 2, today);
        assert!(cells.iter().all(|c| !c.is_today));
    }

    #[test]
    fn other_month_padding_has_conservative_flags() {
        // Partial / "old" records: padding cells only have a day number.
        let today = NaiveDate::from_ymd_opt(2026, 8, 19).unwrap();
        let cells = calendar_cells(2026, 8, today);
        let padding: Vec<_> = cells.iter().filter(|c| c.is_other_month).collect();
        assert!(!padding.is_empty());
        for c in padding {
            assert!(!c.is_today);
            assert!(!c.is_weekend);
            assert!(c.day >= 1);
        }
    }
}
