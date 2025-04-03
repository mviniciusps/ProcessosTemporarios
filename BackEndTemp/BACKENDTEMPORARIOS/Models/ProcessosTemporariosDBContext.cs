using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace BACKENDTEMPORARIOS.Models;

public partial class ProcessosTemporariosDBContext : DbContext
{
    public ProcessosTemporariosDBContext()
    {
    }

    public ProcessosTemporariosDBContext(DbContextOptions<ProcessosTemporariosDBContext> options)
        : base(options)
    {
    }

    public virtual DbSet<TCeMercante> TCeMercantes { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=Marcus\\SQLEXPRESS;Database=ProcessosTemporarios;User Id=sa;Password=@123456;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TCeMercante>(entity =>
        {
            entity.HasKey(e => e.ICeid).HasName("PK_CE_ID");

            entity.ToTable("tCeMercante");

            entity.HasIndex(e => e.CNumeroCe, "UQ_NUMERO_CE").IsUnique();

            entity.Property(e => e.ICeid)
                .HasDefaultValueSql("(NEXT VALUE FOR [seqID_CE_ID])")
                .HasColumnName("iCEID");
            entity.Property(e => e.CNumeroCe)
                .HasMaxLength(15)
                .IsUnicode(false)
                .IsFixedLength()
                .HasColumnName("cNumeroCE");
            entity.Property(e => e.CStatusCe)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("cStatusCE");
        });
        modelBuilder.HasSequence<int>("seqApoliceID");
        modelBuilder.HasSequence<int>("seqCNPJID");
        modelBuilder.HasSequence<int>("seqContratoID");
        modelBuilder.HasSequence<int>("seqDeclaracaoID");
        modelBuilder.HasSequence<int>("seqID_CE_ID");
        modelBuilder.HasSequence<int>("seqIIDEvento");
        modelBuilder.HasSequence<int>("seqIIDUsuario");
        modelBuilder.HasSequence<int>("seqRecintoID");

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
