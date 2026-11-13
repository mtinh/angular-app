import { Injectable, inject } from '@angular/core';
import { SupabaseService } from './supabase-service';
import { Product } from '../ecommerce/model/product';
@Injectable({ providedIn: 'root' })
export class ProductService {
  private supabase = inject(SupabaseService);
  async getProducts(): Promise<Product[]> {
    const { data, error } = await this.supabase.client
      .from('products')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data as Product[];
  }
}