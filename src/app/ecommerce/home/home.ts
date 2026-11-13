import { Component, inject, OnInit, signal } from '@angular/core';
import { DecimalPipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { NavbarComponent } from '../navbar/navbar';
import { ProductService } from '../../services/product-service';
import { Product } from '../model/Product';

@Component({
  selector: 'app-home',
  imports: [NavbarComponent, RouterLink, DecimalPipe],
  templateUrl: './home.html',
  styleUrl: './home.css',
})
export class HomeComponent implements OnInit {
  private productService = inject(ProductService);
  products = signal<Product[]>([]);
  isLoading = signal<boolean>(true);
  errorMessage = signal<string>('');

  async ngOnInit(): Promise<void> {
    try {
      const data = await this.productService.getProducts();
      this.products.set(data);
    } catch (err) {
      console.error('Lỗi khi gọi Supabase:', err);
      this.errorMessage.set('Không tải được danh sách sản phẩm. Vui lòng thử lại sau.');
    } finally {
      this.isLoading.set(false);
    }
  }

  /** Giá sau khi áp dụng giảm giá (theo % hoặc theo số tiền). */
  finalPrice(item: Product): number {
    if (!item.discount) return item.price;
    const price =
      item.discount_unit === 'PERCENT'
        ? item.price * (1 - item.discount / 100)
        : item.price - item.discount;
    return Math.max(0, price);
  }
}
