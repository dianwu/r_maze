# Quickstart: MVP Core Gameplay Features

This guide provides instructions for setting up the development environment and running the game.

## Prerequisites

-   [Roblox Studio](https://www.roblox.com/create) installed.
-   [Rojo](https://rojo.space/docs/getting-started/installation/) (v7.x or later) installed.
-   [Visual Studio Code](https://code.visualstudio.com/) (or another preferred code editor) with the [Rojo VSC extension](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo).

## Setup

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Create a Rojo project file**:
    Create a `default.project.json` file in the root of the repository with the following content. This file maps the directories in your project to the Roblox game hierarchy.

    ```json
    {
      "name": "r_maze",
      "tree": {
        "$className": "DataModel",

        "ReplicatedStorage": {
          "$className": "ReplicatedStorage",
          "Source": {
            "$path": "src/ReplicatedStorage"
          }
        },

        "ServerScriptService": {
          "$className": "ServerScriptService",
          "Source": {
            "$path": "src/ServerScriptService"
          }
        },

        "StarterPlayer": {
          "$className": "StarterPlayer",
          "StarterPlayerScripts": {
            "$className": "StarterPlayerScripts",
            "Source": {
              "$path": "src/StarterPlayer/StarterPlayerScripts"
            }
          }
        }
      }
    }
    ```

3.  **Start the Rojo server**:
    Open a terminal in the project root and run the following command:
    ```bash
    rojo serve
    ```

4.  **Sync with Roblox Studio**:
    -   Open Roblox Studio.
    -   Create a new Baseplate place or open an existing one.
    -   In the `Plugins` tab, find the Rojo plugin and click `Connect`.
    -   Rojo will now sync your file system with the Roblox place hierarchy.

## Running the Game

-   Once the project is synced with Roblox Studio, you can run the game by clicking the `Play` button (or F5).

## Running Tests

-   Tests are written using `TestEz` and are located in the `src/ServerScriptService/Tests` directory.
-   To run the tests, you will need to use a TestEz runner. You can get one from the Roblox toolbox or by setting one up manually.
-   The tests will run automatically when the game starts in Studio.
