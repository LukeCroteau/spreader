using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SpreaderWeb.Models
{
    public partial class Agents
    {
        public Agents()
        {
            AgentsLog = new HashSet<AgentsLog>();
            AgentsWorkers = new HashSet<AgentsWorkers>();
            Tasks = new HashSet<Tasks>();
        }

        public int Id { get; set; }

        [DataType(DataType.Date)]
        public DateTime? Created { get; set; }
        public bool? Active { get; set; }

        [Display(Name = "Last Seen")]
        [DataType(DataType.DateTime)]
        public DateTime? Lastping { get; set; }

        [Display(Name = "Description")]
        public string Name { get; set; }

        [Display(Name = "PC Name")]
        public string Netname { get; set; }

        [Display(Name = "Client Version")]
        public string Version { get; set; }

        [Display(Name = "CPUs")]
        public int? Cpucount { get; set; }

        [Display(Name = "Memory")]
        public int? Totalmemory { get; set; }

        public virtual ICollection<AgentsLog> AgentsLog { get; set; }
        public virtual ICollection<AgentsWorkers> AgentsWorkers { get; set; }
        public virtual ICollection<Tasks> Tasks { get; set; }
    }
}
