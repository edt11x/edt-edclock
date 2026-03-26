import Clock from './components/Clock';
import DateDisplay from './components/DateDisplay';
import Calendar from './components/Calendar';
import './App.css';

function App() {
  const handleClose = () => {
    window.close();
  };

  return (
    <div className="app-container">
      <div className="window-controls">
        <button className="close-btn" onClick={handleClose} title="Close Application">×</button>
      </div>
      <header className="app-header">
        <Clock />
        <DateDisplay />
      </header>
      <main className="app-main">
        <Calendar />
      </main>
      <div className="drag-handle" title="Drag to move">⋮</div>
    </div>
  );
}

export default App;
