slint::include_modules!();

use chrono::{Datelike, Local, Month, Timelike};
use edt_edclock_slint::calendar::{self, DayCell};
use edt_edclock_slint::cli::{self, Action};
use edt_edclock_slint::clipboard::CLIPBOARD_PHRASE;
use edt_edclock_slint::disk;
use edt_edclock_slint::{window_title, VERSION};
use num_traits::FromPrimitive;
use slint::{ModelRc, SharedString, Timer, TimerMode, VecModel};
use std::cell::Cell;
use std::process::ExitCode;
use std::rc::Rc;
use sysinfo::Disks;

fn get_disk_usage() -> String {
    let disks = Disks::new_with_refreshed_list();
    match disks.list().first() {
        Some(disk) => disk::format_usage(disk.total_space(), disk.available_space()),
        None => disk::format_usage(0, 0),
    }
}

fn to_calendar_day(cell: DayCell) -> CalendarDay {
    CalendarDay {
        day: SharedString::from(cell.day.to_string()),
        is_today: cell.is_today,
        is_weekend: cell.is_weekend,
        is_other_month: cell.is_other_month,
    }
}

fn generate_calendar_days(year: i32, month: u32) -> Vec<CalendarDay> {
    let today = Local::now().date_naive();
    calendar::calendar_cells(year, month, today)
        .into_iter()
        .map(to_calendar_day)
        .collect()
}

fn run_ui() -> Result<(), slint::PlatformError> {
    let ui = AppWindow::new()?;
    ui.set_app_title(SharedString::from(window_title()));
    let ui_handle = ui.as_weak();

    // Shared view date. i32/u32 are Copy; capturing them in several
    // `move` closures would give each button its own stale copy.
    let now = Local::now();
    let view_year = Rc::new(Cell::new(now.year()));
    let view_month = Rc::new(Cell::new(now.month()));

    let update_calendar = {
        let ui_handle = ui_handle.clone();
        move |year: i32, month: u32| {
            if let Some(ui) = ui_handle.upgrade() {
                let month_name = Month::from_u32(month).unwrap().name();
                ui.set_month_year(SharedString::from(format!("{month_name} {year}")));
                let days = generate_calendar_days(year, month);
                let days_model = Rc::new(VecModel::from(days));
                ui.set_calendar_days(ModelRc::from(days_model));
            }
        }
    };

    update_calendar(view_year.get(), view_month.get());

    {
        let update_calendar = update_calendar.clone();
        let view_year = view_year.clone();
        let view_month = view_month.clone();
        ui.on_prev_month(move || {
            let (year, month) = calendar::prev_month(view_year.get(), view_month.get());
            view_year.set(year);
            view_month.set(month);
            update_calendar(year, month);
        });
    }
    {
        let update_calendar = update_calendar.clone();
        let view_year = view_year.clone();
        let view_month = view_month.clone();
        ui.on_next_month(move || {
            let (year, month) = calendar::next_month(view_year.get(), view_month.get());
            view_year.set(year);
            view_month.set(month);
            update_calendar(year, month);
        });
    }
    {
        let update_calendar = update_calendar.clone();
        let view_year = view_year.clone();
        let view_month = view_month.clone();
        ui.on_prev_year(move || {
            let year = view_year.get() - 1;
            view_year.set(year);
            update_calendar(year, view_month.get());
        });
    }
    {
        let update_calendar = update_calendar.clone();
        let view_year = view_year.clone();
        let view_month = view_month.clone();
        ui.on_next_year(move || {
            let year = view_year.get() + 1;
            view_year.set(year);
            update_calendar(year, view_month.get());
        });
    }

    let timer = Timer::default();
    {
        let ui_handle = ui_handle.clone();
        timer.start(
            TimerMode::Repeated,
            std::time::Duration::from_secs(1),
            move || {
                if let Some(ui) = ui_handle.upgrade() {
                    let now = Local::now();
                    ui.set_time_hour(SharedString::from(now.format("%H").to_string()));
                    ui.set_time_min(SharedString::from(now.format("%M").to_string()));
                    ui.set_time_sec(SharedString::from(now.format("%S").to_string()));
                    ui.set_date_text(SharedString::from(
                        now.format("%A, %b %d %Y").to_string(),
                    ));
                    if now.second() == 0 || ui.get_disk_usage().contains("Checking") {
                        ui.set_disk_usage(SharedString::from(get_disk_usage()));
                    }
                }
            },
        );
    }

    ui.on_copy_phrase(|| {
        if let Ok(mut clipboard) = arboard::Clipboard::new() {
            let _ = clipboard.set_text(CLIPBOARD_PHRASE);
        }
    });

    ui.set_disk_usage(SharedString::from(get_disk_usage()));
    ui.run()
}

fn main() -> ExitCode {
    match cli::parse_args(std::env::args()) {
        Action::Help => {
            print!("{}", cli::help_text());
            ExitCode::SUCCESS
        }
        Action::Version => {
            println!("{}", cli::version_text());
            ExitCode::SUCCESS
        }
        Action::Unknown(flag) => {
            eprintln!("{flag}: unknown option");
            eprint!("{}", cli::help_text());
            ExitCode::from(2)
        }
        Action::Run => match run_ui() {
            Ok(()) => ExitCode::SUCCESS,
            Err(err) => {
                eprintln!("edt-edclock-slint {VERSION}: {err}");
                ExitCode::FAILURE
            }
        },
    }
}
