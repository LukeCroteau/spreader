using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace SpreaderWeb.Models
{
    public partial class JobsCron
    {
        public int Id { get; set; }
        public int? Jobid { get; set; }

        [Display(Name = "Created")]
        [DataType(DataType.DateTime)]
        public DateTime? Created { get; set; }

        public bool? Active { get; set; }
        public string Description { get; set; }
        public string Daysofweek { get; set; }
        public int Dayofmonth { get; set; }

        [Display(Name = "Start Time")]
        [DataType(DataType.Time)]
        public TimeSpan Starttime { get; set; }

        public int? Accessid { get; set; }

        [Display(Name = "TaskKey")]
        public string Taskkey { get; set; }

        [Display(Name = "Parameters")]
        public string Params { get; set; }

        [Display(Name = "Last Run")]
        [DataType(DataType.DateTime)]
        public DateTime? LastRun { get; set; }

        public int? LastTaskid { get; set; }

        public virtual JobsAccess Access { get; set; }
        public virtual Jobs Job { get; set; }
        public virtual Tasks LastTask { get; set; }
    }
}
