import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  CircularProgress,
  Container,
  IconButton,
  Card,
  CardContent,
  List,
  ListItem,
  ListItemText,
} from "@mui/material";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { Line } from "react-chartjs-2";
import { getDeviceHistory, calculateEnergyCost, getEnergy, updateHistory } from "../controller/devices";
import { Home as HomeIcon } from "@mui/icons-material";

// Registrar componentes de Chart.js
ChartJS.register(
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend
);

export const Device = () => {
  const { deviceId } = useParams();
  const [device, setDevice] = useState(null);
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isDeviceOn, setIsDeviceOn] = useState(false);
  const [temperature, setTemperature] = useState(20);
  const [energyData, setEnergyData] = useState(null);
  const [totalCost, setTotalCost] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchData = async () => {
      const data = await getDeviceHistory(deviceId);
      setDevice(data.device);
      setHistory(data.history);
      const energyData = await getEnergy(deviceId);
      setEnergyData(energyData.energy_hour);
      const energyCostData = await calculateEnergyCost(deviceId);
      setTotalCost(energyCostData.total_cost);
      setLoading(false);
    };
    fetchData();
  }, [deviceId]);

  const toggleDeviceState = async () => {
    const newState = !isDeviceOn;
    setIsDeviceOn(newState);
    await updateHistory(deviceId, newState, newState ? "Device turned on" : "Device turned off");
  };

  const handleTemperatureChange = async (change) => {
    const newTemperature = temperature + change;
    setTemperature(newTemperature);
    await updateHistory(deviceId, isDeviceOn, `Temperature changed to ${newTemperature}°C`);
  };

  const generateEnergyChartData = (energyData) => {
    return {
      labels: Object.keys(energyData),
      datasets: [
        {
          label: "Energy Consumption",
          data: Object.values(energyData),
          borderColor: "green",
          fill: false,
        },
      ],
    };
  };

  const generateStateChartData = (history) => {
    return {
      labels: history.map((_, index) => index),
      datasets: [
        {
          label: "Device State",
          data: history.map((item) => (item.state ? 1 : 0)),
          borderColor: "blue",
          fill: false,
          stepped: true,
        },
      ],
    };
  };

  return (
    <div>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" style={{ flexGrow: 1 }}>
            Device {deviceId}
          </Typography>
          <Button
            color="inherit"
            startIcon={<HomeIcon />}
            onClick={() => {
              navigate("/home");
            }}
          >
            Home
          </Button>
        </Toolbar>
      </AppBar>
      <Container style={{ marginTop: "20px" }}>
        {loading ? (
          <CircularProgress />
        ) : (
          <div>
            <Card>
              <CardContent>
                <Typography variant="h5">Device Control</Typography>
                <div style={{ display: "flex", alignItems: "center" }}>
                  <IconButton
                    onClick={() => handleTemperatureChange(-1)}
                    disabled={!isDeviceOn}
                  >
                    -
                  </IconButton>
                  <Typography>{temperature}°C</Typography>
                  <IconButton
                    onClick={() => handleTemperatureChange(1)}
                    disabled={!isDeviceOn}
                  >
                    +
                  </IconButton>
                  <Button
                    variant="contained"
                    color={isDeviceOn ? "secondary" : "primary"}
                    onClick={toggleDeviceState}
                    style={{ marginLeft: "20px" }}
                  >
                    {isDeviceOn ? "Turn Off" : "Turn On"}
                  </Button>
                </div>
              </CardContent>
            </Card>
            <Card style={{ marginTop: "20px" }}>
              <CardContent>
                <Typography variant="h5">Device Info</Typography>
                <Typography>ID: {device.id}</Typography>
                <Typography>Name: {device.name}</Typography>
              </CardContent>
            </Card>
            <Card style={{ marginTop: "20px" }}>
              <CardContent>
                <Typography variant="h5">Energy Consumption</Typography>
                {totalCost !== null && (
                  <Typography variant="h6">
                    Total Cost: ${totalCost.toFixed(2)}
                  </Typography>
                )}
                {energyData ? (
                  <Line data={generateEnergyChartData(energyData)} />
                ) : (
                  <CircularProgress />
                )}
              </CardContent>
            </Card>

            <Card style={{ marginTop: "20px" }}>
              <CardContent>
                <Typography variant="h5">Historial de Encendido/Apagado</Typography>
                {history.length > 0 ? (
                  <Line data={generateStateChartData(history)} />
                ) : (
                  <Typography>No history available.</Typography>
                )}
              </CardContent>
            </Card>
            
            <Card style={{ marginTop: "20px" }}>
              <CardContent>
                <Typography variant="h5">History</Typography>
                <List>
                  {history.map((item, index) => (
                    <ListItem key={index}>
                      <ListItemText
                        primary={item.description}
                        secondary={`Date: ${item.date}, State: ${item.state}`}
                      />
                    </ListItem>
                  ))}
                </List>
              </CardContent>
            </Card>
          </div>
        )}
      </Container>
    </div>
  );
};
