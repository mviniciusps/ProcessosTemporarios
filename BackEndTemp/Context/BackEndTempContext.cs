using Microsoft.EntityFrameworkCore;
using Models;

namespace Context;

public class BackEndTempContext : DbContext
{
    public BackEndTempContext(DbContextOptions<BackEndTempContext> options) : base(options)
    {

    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ProcessosAtivos>()
            .HasNoKey()
            .ToView("vTelaPrincipalAtivos");

        modelBuilder.Entity<ProcessosArquivados>()
            .HasNoKey()
            .ToView("vTelaPrincipalArquivados");

        modelBuilder.Entity<InformacoesPorProcesso>(entity =>
        {
            entity.HasNoKey();
        });

        modelBuilder.Entity<ContratosPorProcesso>(entity =>
        {
            entity.HasNoKey();
        });

        modelBuilder.Entity<InformacoesGeraisPorProrrogacao>(entity =>
        {
            entity.HasNoKey();
        });

        modelBuilder.Entity<InformacoesGeraisPorProrrogacaoSegundoQuadro>(entity =>
        {
            entity.HasNoKey();
        });

        modelBuilder.Entity<InformacoesGeraisTodasProrrogacoesPorProcesso>(entity =>
        {
            entity.HasNoKey();
        });
    }


    public DbSet<ProcessosAtivos> processosAtivos { get; set; }
    public DbSet<ProcessosArquivados> processosArquivados { get; set; }
    public DbSet<InformacoesPorProcesso> informacoesPorProcessos { get; set; }
    public DbSet<ContratosPorProcesso> contratosPorProcesso { get; set; }
    public DbSet<InformacoesGeraisPorProrrogacao> informacoesGeraisPorProrrogacao { get; set; }
    public DbSet<InformacoesGeraisPorProrrogacaoSegundoQuadro> informacoesGeraisPorProrrogacaoSegundoQuadro { get; set; }
    public DbSet<InformacoesGeraisTodasProrrogacoesPorProcesso> informacoesGeraisTodasProrrogacoesPorProcesso { get; set; }
}