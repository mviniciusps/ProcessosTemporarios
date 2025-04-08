import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class TabelaDadosService {

  constructor(private http: HttpClient) { }

  getDados() {
    return this.http.get<any[]>('https://localhost:7221/api/ViewDeclaracao');
  }
}
