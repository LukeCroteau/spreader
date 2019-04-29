using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SpreaderWeb.Models
{
    public partial class Tasks
    {
        public Tasks()
        {
            JobsCron = new HashSet<JobsCron>();
        }

        public int Id { get; set; }

        [Display(Name = "Created")]
        [DataType(DataType.DateTime)]
        public DateTime? Created { get; set; }
        public int Jobid { get; set; }

        [Display(Name = "TaskKey")]
        public string Taskkey { get; set; }

        [Display(Name = "Parameters")]
        public string Params { get; set; }

        public bool? Processed { get; set; }
        public bool? Processing { get; set; }

        [Display(Name = "Had Errors")]
        public bool? ProcessedWithErrors { get; set; }

        [Display(Name = "Start Time")]
        [DataType(DataType.DateTime)]
        public DateTime? Starttime { get; set; }

        [Display(Name = "Stop Time")]
        [DataType(DataType.DateTime)]
        public DateTime? Stoptime { get; set; }

        public int? Agentid { get; set; }
        public int? Workerid { get; set; }
        public int? Accessid { get; set; }

        public virtual JobsAccess Access { get; set; }
        public virtual Agents Agent { get; set; }
        public virtual Jobs Job { get; set; }
        public virtual AgentsWorkers Worker { get; set; }
        public virtual ICollection<JobsCron> JobsCron { get; set; }
    }
}
