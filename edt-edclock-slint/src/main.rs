slint::include_modules!();
use chrono::{Datelike, Local, NaiveDate, Month, Timelike};
use num_traits::FromPrimitive;
use sysinfo::{Disks};
use std::rc::Rc;
use slint::{Timer, TimerMode, SharedString, ModelRc, VecModel};

fn get_disk_usage() -> String {
    let disks = Disks::new_with_refreshed_list();
    if let Some(disk) = disks.list().first() {
        let total = disk.total_space();
        let available = disk.available_space();
        let used = total - available;
        let used_pct = (used as f64 / total as f64 * 100.0) as i32;

        fn fmt_size(bytes: u64) -> String {
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

        format!("~ {} free of {} ({}% used)", fmt_size(available), fmt_size(total), used_pct)
    } else {
        "Disk usage unavailable".to_string()
    }
}

fn generate_calendar_days(year: i32, month: u32) -> Vec<CalendarDay> {
    let first_day_of_month = NaiveDate::from_ymd_opt(year, month, 1).unwrap();
    let weekday_of_first = first_day_of_month.weekday().num_days_from_sunday(); // 0 = Sun
    
    let mut days = Vec::new();
    let today = Local::now().date_naive();

    // Previous month padding
    let prev_month_date = if month == 1 {
        NaiveDate::from_ymd_opt(year - 1, 12, 1).unwrap()
    } else {
        NaiveDate::from_ymd_opt(year, month - 1, 1).unwrap()
    };
    let days_in_prev_month = chrono_utils::days_in_month(prev_month_date.year(), prev_month_date.month());
    
    for i in (0..weekday_of_first).rev() {
        let d = days_in_prev_month - i;
        days.push(CalendarDay {
            day: SharedString::from(d.to_string()),
            is_today: false,
            is_weekend: false, // Could calculate but Python version only tints grid headers
            is_other_month: true,
        });
    }

    // Current month
    let days_in_month = chrono_utils::days_in_month(year, month);
    for d in 1..=days_in_month {
        let date = NaiveDate::from_ymd_opt(year, month, d).unwrap();
        let is_weekend = date.weekday().num_days_from_sunday() == 0 || date.weekday().num_days_from_sunday() == 6;
        days.push(CalendarDay {
            day: SharedString::from(d.to_string()),
            is_today: date == today,
            is_weekend,
            is_other_month: false,
        });
    }

    // Next month padding
    let mut d = 1;
    while days.len() < 42 {
        days.push(CalendarDay {
            day: SharedString::from(d.to_string()),
            is_today: false,
            is_weekend: false,
            is_other_month: true,
        });
        d += 1;
    }

    days
}

mod chrono_utils {
    use chrono::NaiveDate;
    pub fn days_in_month(year: i32, month: u32) -> u32 {
        if month == 12 {
            NaiveDate::from_ymd_opt(year + 1, 1, 1).unwrap()
                .signed_duration_since(NaiveDate::from_ymd_opt(year, 12, 1).unwrap())
                .num_days() as u32
        } else {
            NaiveDate::from_ymd_opt(year, month + 1, 1).unwrap()
                .signed_duration_since(NaiveDate::from_ymd_opt(year, month, 1).unwrap())
                .num_days() as u32
        }
    }
}

fn main() -> Result<(), slint::PlatformError> {
    let ui = AppWindow::new()?;
    let ui_handle = ui.as_weak();

    // Initial State
    let now = Local::now();
    let mut view_year = now.year();
    let mut view_month = now.month();

    let update_calendar = {
        let ui_handle = ui_handle.clone();
        move |year: i32, month: u32| {
            if let Some(ui) = ui_handle.upgrade() {
                let month_name = Month::from_u32(month).unwrap().name();
                ui.set_month_year(SharedString::from(format!("{} {}", month_name, year)));
                
                let days = generate_calendar_days(year, month);
                let days_model = Rc::new(VecModel::from(days));
                ui.set_calendar_days(ModelRc::from(days_model));
            }
        }
    };

    update_calendar(view_year, view_month);

    // Callbacks
    {
        let update_calendar = update_calendar.clone();
        ui.on_prev_month(move || {
            if view_month == 1 {
                view_month = 12;
                view_year -= 1;
            } else {
                view_month -= 1;
            }
            update_calendar(view_year, view_month);
        });
    }
    {
        let update_calendar = update_calendar.clone();
        ui.on_next_month(move || {
            if view_month == 12 {
                view_month = 1;
                view_year += 1;
            } else {
                view_month += 1;
            }
            update_calendar(view_year, view_month);
        });
    }
    {
        let update_calendar = update_calendar.clone();
        ui.on_prev_year(move || {
            view_year -= 1;
            update_calendar(view_year, view_month);
        });
    }
    {
        let update_calendar = update_calendar.clone();
        ui.on_next_year(move || {
            view_year += 1;
            update_calendar(view_year, view_month);
        });
    }

    // Timer for Clock and Disk Usage
    let timer = Timer::default();
    {
        let ui_handle = ui_handle.clone();
        timer.start(TimerMode::Repeated, std::time::Duration::from_secs(1), move || {
            if let Some(ui) = ui_handle.upgrade() {
                let now = Local::now();
                ui.set_time_hour(SharedString::from(now.format("%H").to_string()));
                ui.set_time_min(SharedString::from(now.format("%M").to_string()));
                ui.set_time_sec(SharedString::from(now.format("%S").to_string()));
                ui.set_date_text(SharedString::from(now.format("%A, %b %d %Y").to_string()));
                
                // Update disk usage every minute (or every second for simplicity here)
                if now.second() == 0 || ui.get_disk_usage().contains("Checking") {
                    ui.set_disk_usage(SharedString::from(get_disk_usage()));
                }
            }
        });
    }

    // Immediate disk usage update
    ui.set_disk_usage(SharedString::from(get_disk_usage()));

    ui.run()
}
