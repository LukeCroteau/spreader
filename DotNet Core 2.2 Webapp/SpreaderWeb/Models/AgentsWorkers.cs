using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SpreaderWeb.Models
{
    public partial class AgentsWorkers
    {
        public AgentsWorkers()
        {
            AgentsLog = new HashSet<AgentsLog>();
            AgentsWorkersAccess = new HashSet<AgentsWorkersAccess>();
            Tasks = new HashSet<Tasks>();
        }

        public int Id { get; set; }

        [Display(Name = "Created")]
        [DataType(DataType.DateTime)]
        public DateTime? Created { get; set; }

        public bool? Active { get; set; }

        [Display(Name = "Last Seen")]
        [DataType(DataType.DateTime)]
        public DateTime? Lastping { get; set; }

        public int? Agentid { get; set; }
        public int? Jobid { get; set; }
        public string Version { get; set; }

        public virtual Agents Agent { get; set; }
        public virtual Jobs Job { get; set; }
        public virtual ICollection<AgentsLog> AgentsLog { get; set; }
        public virtual ICollection<AgentsWorkersAccess> AgentsWorkersAccess { get; set; }
        public virtual ICollection<Tasks> Tasks { get; set; }
    }

    public partial class AgentsWorkersView
    {
        public int Id { get; set; }

        [Display(Name = "Created")]
        [DataType(DataType.DateTime)]
        public DateTime? AgentsWorkersCreated { get; private set; }

        public bool Active { get; private set; }

        [Display(Name = "Last Seen")]
        [DataType(DataType.DateTime)]
        public DateTime? Lastping { get; private set; }

        public int? Agentid { get; set; }

        [Display(Name = "Agent Name")]
        public string Agentname { get; private set; }

        [Display(Name = "Machine Name")]
        public string Netname { get; private set; }

        public int? JobId { get; private set; }

        [Display(Name = "Job Name")]
        public string JobName { get; private set; }

        [Display(Name = "Version")]
        public string Version { get; private set; }

        [Display(Name = "Access Codes")]
        public string Accesscodes { get; private set; }
    }
}
