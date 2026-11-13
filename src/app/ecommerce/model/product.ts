export interface Product {
    id: number;
    title_prod: string;
    code: string;
    category_id: number | null;
    brand_id: number | null;
    price: number;
    discount: number;
    discount_unit: 'PERCENT' | 'PRICE';
    qty: number;
    specifications: string | null;
    description: string | null;
    img_1: string | null;
    img_2: string | null;
    img_3: string | null;
    created_at: string;
    updated_at: string;
}