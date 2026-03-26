import { useState, useEffect } from 'react';

const DateDisplay = () => {
  const [date, setDate] = useState(new Date());

  useEffect(() => {
    // Update every minute is enough for date, or just every second to stay in sync with clock.
    const timer = setInterval(() => {
      setDate(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const formatDate = (date: Date) => {
    const dayName = new Intl.DateTimeFormat('en-US', { weekday: 'long' }).format(date);
    const fullDate = new Intl.DateTimeFormat('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    }).format(date);

    return { dayName, fullDate };
  };

  const { dayName, fullDate } = formatDate(date);

  return (
    <div className="date-display-container">
      <div className="day-name">{dayName}</div>
      <div className="full-date">{fullDate}</div>
    </div>
  );
};

export default DateDisplay;
