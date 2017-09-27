﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace E2ETests.Helpers
{
    public class DockerUtils
    {
        internal static string DockerComposeBaseCommandFormat = "/c docker-compose";
        internal static string DockerBaseCommandFormat = "/c docker";

        public static void ExecuteDockerComposeCommand(string action, string dockerComposeFile)
        {
            string dockerComposeFullCommandFormat = string.Format("{0} -f {1} {2}", DockerComposeBaseCommandFormat, dockerComposeFile, action);
            CommandLineUtils.ExecuteCommandInCmd(dockerComposeFullCommandFormat);
        }
        public static string ExecuteDockerCommand(string command)
        {
            string dockerFullCommand = string.Format("{0} {1}", DockerBaseCommandFormat, command);
            string output = CommandLineUtils.ExecuteCommandInCmd(dockerFullCommand);
            return output;
        }

        public static void RestartDockerContainer(string containerName)
        {
            ExecuteDockerCommand("restart " + containerName);
        }

        public static string FindIpDockerContainer(string containerName, string networkName = "nat")
        {
            string commandToFindIp = "inspect -f \"{{.NetworkSettings.Networks.nat.IPAddress}}\" "+ containerName;            
            string ip = ExecuteDockerCommand(commandToFindIp).Trim();
            return ip;
        }

        public static void PrintDockerProcessStats(string message)
        {
            Trace.WriteLine("Docker PS Stats at " + message);
            ExecuteDockerCommand("ps -a");
        }
    }
}
