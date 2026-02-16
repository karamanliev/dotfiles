import React from "react";
import {
  List,
  ActionPanel,
  Action,
  Icon,
  closeMainWindow,
  PopToRootType,
} from "@vicinae/api";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

type RecordingMode = {
  icon: string;
  title: string;
  command: string;
};

const recordingModes: RecordingMode[] = [
  {
    icon: "⏺️",
    title: "Toggle Recording",
    command: "toggle-recording",
  },
  {
    icon: "⏯️",
    title: "Pause/Resume Recording",
    command: "pause",
  },
  {
    icon: "🔄",
    title: "Toggle Replay",
    command: "toggle-replay",
  },
  {
    icon: "💾",
    title: "Save Replay",
    command: "save-replay",
  },
];

export default function GSRCommand({ displayName }: { displayName: string }) {
  const executeGSRCommand = async (command: string) => {
    try {
      await closeMainWindow({
        popToRootType: PopToRootType.Suspended,
        clearRootSearch: true,
      });
      await execAsync(`$HOME/.local/bin/gsr.sh ${command} ${displayName}`);
    } catch (error) {
      console.error(`Failed to execute GSR command: ${error}`);
    }
  };

  return (
    <List
      searchBarPlaceholder={`Search recording modes for [${displayName}]...`}
    >
      <List.Section title={`[${displayName}]`} subtitle="Choose mode:">
        {recordingModes.map((mode) => (
          <List.Item
            key={mode.command}
            title={mode.title}
            icon={mode.icon}
            actions={
              <ActionPanel>
                <Action
                  title={mode.title}
                  icon={Icon.Play}
                  onAction={() => executeGSRCommand(mode.command)}
                />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>
    </List>
  );
}
