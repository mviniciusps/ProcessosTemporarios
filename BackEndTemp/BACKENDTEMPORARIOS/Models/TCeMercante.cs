using System;
using System.Collections.Generic;

namespace BACKENDTEMPORARIOS.Models;

public partial class TCeMercante
{
    public int? ICeid { get; set; }

    public string CStatusCe { get; set; } = null!;

    public string? CNumeroCe { get; set; }
}
