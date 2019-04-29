using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SpreaderWeb.Models
{
    public partial class AgentsLog
    {
        public int Id { get; set; }
        public DateTime? Created { get; set; }
        public int? Agentid { get; set; }
        public int? Jobid { get; set; }
        public int? Taskid { get; set; }
        public int? Workerid { get; set; }
        public int? LogType { get; set; }
        public string Message { get; set; }

        public virtual Agents Agent { get; set; }
        public virtual Jobs Job { get; set; }
        public virtual AgentsLogTypes LogTypeNavigation { get; set; }
        public virtual AgentsWorkers Worker { get; set; }
    }

    public partial class AgentsLogView
    {
        public int Id { get; set; }

        [Display(Name = "Created")]
        [DataType(DataType.DateTime)]
        public DateTime? AgentsLogCreated { get; private set; }

        public int? AgentId { get; private set; }

        [Display(Name = "Agent Name")]
        public string AgentName { get; private set; }

        public int? LogType { get; private set; }

        [Display(Name = "Log Type")]
        public string LogTypeDescription { get; private set; }

        [Display(Name = "Message")]
        public string Message { get; private set; }

        public int? JobId { get; private set; }

        [Display(Name = "Job Name")]
        public string JobName { get; private set; }

        public int? TaskId { get; private set; }

        [Display(Name = "TaskKey")]
        public string TaskKey { get; private set; }

        public int? WorkerId { get; private set; }
    }
}
