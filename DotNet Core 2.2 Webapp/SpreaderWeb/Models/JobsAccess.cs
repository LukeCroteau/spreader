using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SpreaderWeb.Models
{
    public partial class JobsAccess
    {
        public JobsAccess()
        {
            AgentsWorkersAccess = new HashSet<AgentsWorkersAccess>();
            JobsCron = new HashSet<JobsCron>();
            Tasks = new HashSet<Tasks>();
        }

        public int Id { get; set; }
        public int Jobid { get; set; }

        [Display(Name = "Created")]
        [DataType(DataType.DateTime)]
        public DateTime? Created { get; set; }

        public string Code { get; set; }
        public string Name { get; set; }

        public virtual Jobs Job { get; set; }
        public virtual ICollection<AgentsWorkersAccess> AgentsWorkersAccess { get; set; }
        public virtual ICollection<JobsCron> JobsCron { get; set; }
        public virtual ICollection<Tasks> Tasks { get; set; }
    }
}
