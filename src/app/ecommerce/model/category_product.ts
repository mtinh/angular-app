export interface CategoryProduct {
    id: number;
    name: string;
    slug: string;
    parent_id: number | null;
    description: string | null;
    image: string | null;
    created_at: string;
    updated_at: string;
}
