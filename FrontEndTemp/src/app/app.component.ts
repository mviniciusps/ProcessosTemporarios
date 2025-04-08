import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TabelaDadosComponent } from './tabela-dados/tabela-dados.component';

@Component({
  selector: 'app-root',
  imports: [TabelaDadosComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'FrontEndTemp';
}