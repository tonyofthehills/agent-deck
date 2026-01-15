# React Native Development Guide

**Agent Deck - React Native + Expo Patterns**

Comprehensive guide for developing the Agent Deck mobile application using React Native and Expo.

**Last Updated**: 2025-01-24

---

## Table of Contents

1. [Expo Project Structure](#expo-project-structure)
2. [Creating Screens and Components](#creating-screens-and-components)
3. [useWebSocket Hook Pattern](#usewebsocket-hook-pattern)
4. [Keep Screen Awake Implementation](#keep-screen-awake-implementation)
5. [QR Scanner Implementation](#qr-scanner-implementation)
6. [AsyncStorage for Persistence](#asyncstorage-for-persistence)
7. [Navigation with @react-navigation](#navigation-with-react-navigation)
8. [Theme and Dark Mode](#theme-and-dark-mode)
9. [Shared Types Usage](#shared-types-usage)

---

## Expo Project Structure

### app.json Configuration

```json
{
  "expo": {
    "name": "Agent Deck",
    "slug": "agent-deck-mobile",
    "version": "1.0.0",
    "platforms": ["ios", "android"],
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "backgroundColor": "#1a1a1a"
    },
    "ios": {
      "bundleIdentifier": "com.agentdeck.mobile",
      "supportsTablet": true
    },
    "android": {
      "package": "com.agentdeck.mobile",
      "adaptiveIcon": {
        "foregroundImage": "./assets/icon.png",
        "backgroundColor": "#1a1a1a"
      }
    }
  }
}
```

---

## Creating Screens and Components

### AgentListScreen.tsx

**Main agent monitoring screen with real-time updates**

```typescript
import React from 'react';
import { FlatList, StyleSheet, View } from 'react-native';
import { AgentCard } from '../components/AgentCard';
import { ConnectionStatus } from '../components/ConnectionStatus';
import { useWebSocket } from '../hooks/useWebSocket';
import type { AgentInstance } from '@agent-deck/shared-types';

export function AgentListScreen() {
  const { agents, connected, sendFocusCommand } = useWebSocket();

  const handleFocus = (agent: AgentInstance) => {
    sendFocusCommand(agent.id);
  };

  return (
    <View style={styles.container}>
      <ConnectionStatus connected={connected} />
      <FlatList
        data={agents}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <AgentCard agent={item} onPress={() => handleFocus(item)} />
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
});
```

---

### AgentCard.tsx

**Agent status card component with interactive press states**

```typescript
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import type { AgentInstance } from '@agent-deck/shared-types';

interface AgentCardProps {
  agent: AgentInstance;
  onPress: () => void;
}

export function AgentCard({ agent, onPress }: AgentCardProps) {
  const statusColor = {
    idle: '#666',
    running: '#4ade80',
    error: '#f87171',
  }[agent.status];

  return (
    <Pressable
      style={({ pressed }) => [
        styles.card,
        { borderLeftColor: statusColor },
        pressed && styles.pressed,
      ]}
      onPress={onPress}
    >
      <Text style={styles.name}>{agent.name}</Text>
      <Text style={styles.task}>{agent.currentTask || 'Idle'}</Text>
      {agent.branch && <Text style={styles.branch}>Branch: {agent.branch}</Text>}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#2a2a2a',
    borderLeftWidth: 4,
    borderRadius: 8,
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    minHeight: 44, // Touch target size
  },
  pressed: {
    opacity: 0.8,
    transform: [{ scale: 0.98 }],
  },
  name: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  task: {
    color: '#aaa',
    fontSize: 14,
    marginTop: 4,
  },
  branch: {
    color: '#888',
    fontSize: 12,
    marginTop: 4,
  },
});
```

---

## useWebSocket Hook Pattern

### hooks/useWebSocket.ts

**Custom hook for WebSocket connection management with auto-reconnect**

```typescript
import { useState, useEffect, useCallback, useRef } from 'react';
import type { AgentInstance, WebSocketMessage } from '@agent-deck/shared-types';

export function useWebSocket() {
  const [agents, setAgents] = useState<AgentInstance[]>([]);
  const [connected, setConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();

  const connect = useCallback((url: string) => {
    try {
      const ws = new WebSocket(url);

      ws.onopen = () => {
        console.log('Connected to Agent Deck');
        setConnected(true);
      };

      ws.onmessage = (event) => {
        const message: WebSocketMessage = JSON.parse(event.data);

        if (message.type === 'update') {
          setAgents(message.agents);
        }
      };

      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
      };

      ws.onclose = () => {
        console.log('Disconnected, reconnecting...');
        setConnected(false);

        // Auto-reconnect after 2 seconds
        reconnectTimeoutRef.current = setTimeout(() => {
          connect(url);
        }, 2000);
      };

      wsRef.current = ws;
    } catch (error) {
      console.error('Failed to connect:', error);
    }
  }, []);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
  }, []);

  const sendFocusCommand = useCallback((agentId: string) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'focus',
        agentId,
      }));
    }
  }, []);

  useEffect(() => {
    return () => {
      disconnect();
    };
  }, [disconnect]);

  return {
    agents,
    connected,
    connect,
    disconnect,
    sendFocusCommand,
  };
}
```

---

## Keep Screen Awake Implementation

### hooks/useKeepAwake.ts

**Prevent screen from sleeping during agent monitoring**

```typescript
import { useEffect } from 'react';
import { activateKeepAwake, deactivateKeepAwake } from 'expo-keep-awake';

export function useKeepAwake() {
  useEffect(() => {
    // Prevent screen from sleeping while monitoring agents
    activateKeepAwake();

    return () => {
      deactivateKeepAwake();
    };
  }, []);
}
```

### Usage in AgentListScreen

```typescript
import { useKeepAwake } from '../hooks/useKeepAwake';

export function AgentListScreen() {
  useKeepAwake(); // Screen stays awake while on this screen

  // ... rest of component
}
```

---

## QR Scanner Implementation

### screens/QRScannerScreen.tsx

**QR code scanner for pairing with Mac app**

```typescript
import React, { useState, useEffect } from 'react';
import { Text, View, StyleSheet, Button } from 'react-native';
import { BarCodeScanner } from 'expo-barcode-scanner';

interface QRScannerScreenProps {
  onScan: (url: string) => void;
}

export function QRScannerScreen({ onScan }: QRScannerScreenProps) {
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [scanned, setScanned] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await BarCodeScanner.requestPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const handleBarCodeScanned = ({ data }: { data: string }) => {
    setScanned(true);

    // Validate URL format: ws://192.168.x.x:3000
    if (data.startsWith('ws://') || data.startsWith('http://')) {
      onScan(data);
    } else {
      alert('Invalid QR code format');
    }
  };

  if (hasPermission === null) {
    return <Text style={styles.text}>Requesting camera permission...</Text>;
  }

  if (hasPermission === false) {
    return <Text style={styles.text}>No access to camera</Text>;
  }

  return (
    <View style={styles.container}>
      <BarCodeScanner
        onBarCodeScanned={scanned ? undefined : handleBarCodeScanned}
        style={StyleSheet.absoluteFillObject}
      />
      {scanned && (
        <Button title="Tap to Scan Again" onPress={() => setScanned(false)} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  text: {
    color: '#fff',
    textAlign: 'center',
  },
});
```

---

## AsyncStorage for Persistence

### utils/storage.ts

**Persistent storage utilities for connection settings**

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

const KEYS = {
  SERVER_URL: '@agent_deck:server_url',
  LAST_CONNECTED: '@agent_deck:last_connected',
};

export async function saveServerUrl(url: string): Promise<void> {
  try {
    await AsyncStorage.setItem(KEYS.SERVER_URL, url);
  } catch (error) {
    console.error('Failed to save server URL:', error);
  }
}

export async function getServerUrl(): Promise<string | null> {
  try {
    return await AsyncStorage.getItem(KEYS.SERVER_URL);
  } catch (error) {
    console.error('Failed to get server URL:', error);
    return null;
  }
}

export async function saveLastConnectedTimestamp(): Promise<void> {
  try {
    await AsyncStorage.setItem(KEYS.LAST_CONNECTED, Date.now().toString());
  } catch (error) {
    console.error('Failed to save timestamp:', error);
  }
}
```

---

## Navigation with @react-navigation

### App.tsx

**Root navigation configuration**

```typescript
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AgentListScreen } from './src/screens/AgentListScreen';
import { QRScannerScreen } from './src/screens/QRScannerScreen';
import { SettingsScreen } from './src/screens/SettingsScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="AgentList"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#1a1a1a',
          },
          headerTintColor: '#fff',
        }}
      >
        <Stack.Screen
          name="AgentList"
          component={AgentListScreen}
          options={{ title: 'Agent Deck' }}
        />
        <Stack.Screen
          name="QRScanner"
          component={QRScannerScreen}
          options={{ title: 'Scan QR Code' }}
        />
        <Stack.Screen
          name="Settings"
          component={SettingsScreen}
          options={{ title: 'Settings' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

---

## Theme and Dark Mode

### theme/colors.ts

**Color system for dark mode UI**

```typescript
export const colors = {
  background: '#1a1a1a',
  card: '#2a2a2a',
  text: '#ffffff',
  textSecondary: '#aaaaaa',
  textTertiary: '#888888',
  border: '#333333',

  // Status colors
  statusIdle: '#666666',
  statusRunning: '#4ade80',
  statusError: '#f87171',

  // Accent
  primary: '#3b82f6',
  primaryPressed: '#2563eb',
};
```

### Usage in Components

```typescript
import { colors } from '../theme/colors';

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.background,
  },
  card: {
    backgroundColor: colors.card,
  },
  text: {
    color: colors.text,
  },
});
```

---

## Shared Types Usage

### In Mobile App (apps/mobile/src/types/index.ts)

```typescript
// Import from shared package
import type { AgentInstance, AgentStatus, WebSocketMessage } from '@agent-deck/shared-types';

// Use in components
export interface AgentListProps {
  agents: AgentInstance[];
  onFocus: (agent: AgentInstance) => void;
}
```

### In Shared Types Package (packages/shared-types/src/agent.ts)

```typescript
export interface AgentInstance {
  id: string;
  pid: number;
  name: string;
  agentType: 'claude-code' | 'cursor' | 'windsurf';
  cwd: string;
  status: AgentStatus;
  currentTask?: string;
  branch?: string;
  model?: string;
}

export enum AgentStatus {
  idle = 'idle',
  running = 'running',
  error = 'error',
}
```

---

## Running and Testing

### Start Expo Dev Server

```bash
pnpm mobile
```

### Test on iOS Simulator

```bash
pnpm mobile:ios
```

### Test on Android Emulator

```bash
pnpm mobile:android
```

### Test on Physical Device

1. Install Expo Go from App Store (iOS) or Play Store (Android)
2. Run `pnpm mobile`
3. Scan QR code with Expo Go app

---

## Related Documentation

- **[CLAUDE.md](../../CLAUDE.md)** - Main project guide
- **[QUICK_START.md](./QUICK_START.md)** - Quick start guide
- **[SWIFT_GUIDE.md](./SWIFT_GUIDE.md)** - Swift patterns for Mac app
- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** - Testing procedures

---

**Version**: 1.0
**Extracted from**: CLAUDE.md (Agent Deck project)
**Last Updated**: 2025-01-24
