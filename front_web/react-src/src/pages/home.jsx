import React, { useState, useEffect } from "react";
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  List,
  ListItem,
  ListItemText,
  ListItemButton,
  CircularProgress,
  Container,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import { getDevicesUser } from "../controller/devices";
import { createHomeAssistant, getHomeAssistant } from "../controller/homeassistantAPI";

const fetchDevices = async () => {
  const userId = localStorage.getItem('userId');
  const response = await getDevicesUser(userId);
  return response[0];
};

const addHomeAssistant = async (url, token) => {
  if (!url || !token) {
    alert("URL and Token are required");
    return;
  }

  try {
    const response = await createHomeAssistant(url, token);
    if (response.error) {
      alert(response.error);
    }

    alert("Home Assistant added successfully");
  } catch (error) {
    alert("An error occurred while adding Home Assistant");
  }
};

const syncHomeAssistant = async (devices) => {
  try {
    const homeAssistantData = await getHomeAssistant(devices[0].id);
    if (homeAssistantData.error) {
      alert("Home Assistant not synchronized with your devices");
    } else {
      alert("Home Assistant synchronized with your devices");
    }
  } catch (error) {
    console.log(error);
    alert("An error occurred while synchronizing Home Assistant");
  }
};

const addDevice = async (name) => {
  console.log("Device added:", name);
};

const logout = () => {
  localStorage.removeItem('userId');
  localStorage.removeItem('access');
  localStorage.removeItem('refresh');
  window.location.href = '/';
};

export const Home = () => {
  const [haAdded, setHaAdded] = useState(false);
  const [devices, setDevices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [url, setUrl] = useState("");
  const [token, setToken] = useState("");
  const [newDeviceName, setNewDeviceName] = useState("");
  const [showAddHaDialog, setShowAddHaDialog] = useState(false);
  const [showAddDeviceDialog, setShowAddDeviceDialog] = useState(false);

  useEffect(() => {
    const loadDevices = async () => {
      const data = await fetchDevices();
      setDevices(data);
      setLoading(false);
    };
    loadDevices();
  }, []);

  const handleAddHa = async () => {
    console.log(devices);
    if (!devices || devices.length === 0) {
      await addHomeAssistant(url, token);
    } else {
      const homeAssistantData = await getHomeAssistant(devices[0].id);
      console.log(homeAssistantData);

      if (homeAssistantData.error) {
        await addHomeAssistant(url, token);
      } else {
        alert("Home Assistant already synchronized with your devices");
      }

      setHaAdded(true);
      setShowAddHaDialog(false);
    }
  };

  const handleSyncHa = async (devices) => {
    await syncHomeAssistant(devices);
    setHaAdded(true);
  };

  const handleAddDevice = async () => {
    await addDevice(newDeviceName);
    setDevices([...devices, { id: devices.length + 1, name: newDeviceName }]);
    setShowAddDeviceDialog(false);
  };

  return (
    <div>
      {/* AppBar */}
      <AppBar position="static" color="primary">
        <Toolbar>
          <Typography variant="h6" style={{ flexGrow: 1 }}>
            Home Page
          </Typography>
          <Button color="inherit" onClick={logout}>
            Logout
          </Button>
          {!haAdded && devices.length === 0 && (
            <Button
              color="inherit"
              onClick={() => setShowAddHaDialog(true)}
              startIcon={<AddIcon />}
            >
              Add Home Assistant
            </Button>
          )}
          {!haAdded && devices.length > 0 && (
            <Button
              color="inherit"
              onClick={() => handleSyncHa(devices)}
              startIcon={<AddIcon />}
            >
              Sync Home Assistant
            </Button>
          )}
        </Toolbar>
      </AppBar>

      {/* Content */}
      <Container style={{ marginTop: "20px" }}>
        {loading ? (
          <CircularProgress />
        ) : devices.length === 0 ? (
          <Button
            variant="contained"
            color="primary"
            onClick={() => setShowAddDeviceDialog(true)}
            startIcon={<AddIcon />}
          >
            Add Device
          </Button>
        ) : (
          <List>
            {devices.map((device) => (
              <ListItem key={device.id}>
                <ListItemButton>
                  <ListItemText
                    primary={device.name}
                    secondary={`ID: ${device.id}`}
                  />
                </ListItemButton>
              </ListItem>
            ))}
            <ListItem>
              <Button
                variant="contained"
                color="secondary"
                onClick={() => setShowAddDeviceDialog(true)}
                startIcon={<AddIcon />}
                fullWidth
              >
                Add Device
              </Button>
            </ListItem>
          </List>
        )}
      </Container>

      {/* Add Home Assistant Dialog */}
      <Dialog open={showAddHaDialog} onClose={() => setShowAddHaDialog(false)}>
        <DialogTitle>Add Home Assistant</DialogTitle>
        <DialogContent>
          <TextField
            label="URL"
            fullWidth
            margin="normal"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
          />
          <TextField
            label="Token"
            fullWidth
            margin="normal"
            type="password"
            value={token}
            onChange={(e) => setToken(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowAddHaDialog(false)}>Cancel</Button>
          <Button variant="contained" color="primary" onClick={handleAddHa}>
            Add
          </Button>
        </DialogActions>
      </Dialog>

      {/* Add Device Dialog */}
      <Dialog open={showAddDeviceDialog} onClose={() => setShowAddDeviceDialog(false)}>
        <DialogTitle>Add Device</DialogTitle>
        <DialogContent>
          <TextField
            label="Device Name"
            fullWidth
            margin="normal"
            value={newDeviceName}
            onChange={(e) => setNewDeviceName(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowAddDeviceDialog(false)}>Cancel</Button>
          <Button variant="contained" color="primary" onClick={handleAddDevice}>
            Add
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
};