import { useState } from 'react';

const Calendar = () => {
  const [viewDate, setViewDate] = useState(new Date());
  const today = new Date();

  const changeMonth = (offset: number) => {
    const nextDate = new Date(viewDate);
    nextDate.setMonth(nextDate.getMonth() + offset);
    setViewDate(nextDate);
  };

  const changeYear = (offset: number) => {
    const nextDate = new Date(viewDate);
    nextDate.setFullYear(nextDate.getFullYear() + offset);
    setViewDate(nextDate);
  };

  const daysInMonth = (year: number, month: number) => {
    return new Date(year, month + 1, 0).getDate();
  };

  const firstDayOfMonth = (year: number, month: number) => {
    return new Date(year, month, 1).getDay();
  };

  const renderDays = () => {
    const year = viewDate.getFullYear();
    const month = viewDate.getMonth();
    const totalDays = daysInMonth(year, month);
    const firstDay = firstDayOfMonth(year, month);

    const days = [];
    // Empty slots for days before the 1st
    for (let i = 0; i < firstDay; i++) {
      days.push(<div key={`empty-${i}`} className="calendar-day empty"></div>);
    }

    // Days of the month
    for (let day = 1; day <= totalDays; day++) {
      const isToday =
        day === today.getDate() &&
        month === today.getMonth() &&
        year === today.getFullYear();

      days.push(
        <div
          key={day}
          className={`calendar-day ${isToday ? 'today' : ''}`}
        >
          {day}
        </div>
      );
    }

    return days;
  };

  const monthName = new Intl.DateTimeFormat('en-US', { month: 'long' }).format(viewDate);
  const year = viewDate.getFullYear();

  const weekdayInitials = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  return (
    <div className="calendar-container">
      <div className="calendar-header">
        <div className="nav-controls">
          <button onClick={() => changeYear(-1)}>«</button>
          <button onClick={() => changeMonth(-1)}>‹</button>
        </div>
        <div className="month-year-display">
          {monthName} {year}
        </div>
        <div className="nav-controls">
          <button onClick={() => changeMonth(1)}>›</button>
          <button onClick={() => changeYear(1)}>»</button>
        </div>
      </div>
      <div className="calendar-weekdays">
        {weekdayInitials.map((day, idx) => (
          <div key={idx} className="weekday">
            {day}
          </div>
        ))}
      </div>
      <div className="calendar-grid">{renderDays()}</div>
    </div>
  );
};

export default Calendar;
